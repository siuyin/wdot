#!/usr/bin/env ruby

# = wdot.rb - Workflow / Flowchart extensions to grahpviz's dot language.
# License: GPL v2 or (at your option) any later version. See http://www.fsf.org/licensing .
#
# Copyright (C) 2008, Loh Siu Yin (siuyin@beyondbroadcast.com)
#
# Graphviz's dot language ( http://www.graphviz.org ) is a very flexible
# language that can generate graph images (.png, .svg etc) from a text file.
# However for creating workflow diagrams dot is very repetitious and rather
# verbose. In the spirit of "Don't Repeat Yourself", I wrote wdot.rb to
# eliminate most of the repetitious effort while still retaining the full
# flexibility of dot when I need it.
#
# wdot.rb allows you to quickly create workflow diagrams / flowcharts
# easily from text files. As text files these can be updated with any
# text editor resulting in easily updateable diagrams.
#
# == Usage
# wdot.rb < <sourcefile> | dot -T<fmt> -o <outputfile>
#  eg. wdot.rb < my_diagram.wdot | dot -Tpng -o my_diagram.png
#
# == Examples
#  # my_diagram.wdot
#  :head  {
#  _start
#  _end
#  proc1
#  _start->proc1->_end
#  }
#  produces: 
# link:img/d010.png
# ---
#  # my_diagram.wdot - with title and LR orientation
#  :head  "My Diagram", LR {
#  _start
#  _end
#  proc1
#  _start->proc1->_end
#  }
#  produces: 
# link:img/d020.png
# ---
#  # my_diagram.wdot - with title, LR orientation, no arrows
#  :head  "My Diagram", LR {
#  _start
#  _end
#  proc1
#  proc2
#  _start->proc1
#  proc1--proc2
#  proc2->_end
#  }
#  produces: 
# link:img/d021.png
# ---
#  # my_diagram.wdot - with title, LR orientation, back arrow
#  :head  "My Diagram", LR {
#  _start
#  _end
#  proc1
#  proc2
#  _start->proc1
#  proc1<-proc2
#  proc2->_end
#  }
#  produces: 
# link:img/d022.png
# ---
#  # my_diagram.wdot - with title, LR orientation, bi-directional arrow
#  :head  "My Diagram", LR {
#  _start
#  _end
#  proc1
#  proc2
#  _start->proc1
#  proc1<->proc2
#  proc2->_end
#  }
#  produces: 
# link:img/d023.png
# ---
#  # my_diagram.wdot - node descriptions
#  :head  "My Diagram", LR {
#  _start "Start here."
#  _end "All done."
#  proc1 "Complex\nprocessing\nhere."
#  _start->proc1->_end
#  }
#  produces: 
# link:img/d030.png
# ---
#  # my_diagram.wdot - edge descriptions
#  :head  "My Diagram", LR {
#  _start "Start"
#  _end "Done"
#  proc1 "Complex\nprocessing\nhere."
#  _start->proc1 "begin"
#  proc1->_end "finish up"
#  }
#  produces: 
# link:img/d040.png
# ---
#  # my_diagram.wdot - if .. then .. else
#  :head  "My Diagram", LR {
#  _start "Start"
#  _end "Done"
#  proc1 "Complex\nprocessing\nhere."
#  if_check_ok
#
#  _start->proc1 
#  proc1->if_check_ok
#  if_check_ok->_end "Y"
#  if_check_ok->proc1 "N: redo"
#  }
#  produces: 
# link:img/d050.png
# ---
#  # my_diagram.wdot - comments
#  /* My workflow diagram.
#   */
#  :head  "My Diagram", LR {
#  // Nodes - note: leading whitespace or blank lines not significant
#  _start "Start"
#  _end "Done"
#  proc1 "Complex\nprocessing\nhere."
#  if_check_ok "Check:\na. This\nb. That\nAll OK?"
#
#  // Links
#  _start->proc1 
#  proc1->if_check_ok
#  if_check_ok->_end "Y"
#  if_check_ok->proc1 "N: redo"
#  }
#  produces: 
# link:img/d060.png
# ---
#  # my_diagram.wdot - override using underlying dot for flexibility.
#  /* My workflow diagram.
#   */
#  :head  "My Diagram", LR {
#  // Nodes - note: leading whitespace or blank lines not significant
#  _start "Start"
#  _end "Done"
#  proc1 [label="Dangerous Process" fillcolor="red" shape="hexagon"]
#  if_check_ok "Check:\na. This\nb. That\nAll OK?"
#
#  // Links
#  _start->proc1 
#  proc1->if_check_ok
#  if_check_ok->_end "Y"
#  if_check_ok->proc1 [label="N: redo" fontcolor="red" color="magenta" style="bold" arrowtail="inv"]
#  }
#  produces: 
# link:img/d070.png
# == Frequently Asked Questions?
# See here[link:files/FAQ.html].
#
# == Requirements
# * wdot.rb -- this file. Download from http://www.beyondbroadcast.com/cms/wdot 
#   or from http://rubyforge.org/projects/wdot 
# * graphviz -- download from http://www.graphviz.org
# * ruby -- download from http://www.ruby-lang.org
#

# Wdot class - definitions checked:
# * head
# * start_node
# * node
# * if_node
# * edge

class Wdot
  # Class variables.
  @@rankdir = 'TB'
  @@graph_fontname = 'Arial'
  @@graph_bgcolor = 'white'

  @@node_fontname = 'Arial'
  @@node_shape = 'box'
  @@node_style = 'filled'
  @@node_fillcolor = 'AliceBlue'

  @@edge_fontname = 'Arial'
  @@edge_color = 'Blue'
  @@edge_dir = 'forward'

  @@start_node_shape = 'circle'
  @@start_node_fillcolor = 'LightPink'

  # Pattern to isolate words in a line - used by Wdot.split.
  Word_pat = /(?:"[^"]+"|[^\s,(->)]+)/
  
  # Pattern to match :head tag.
  Head_pat = /\s*:head\b\s*(.*)$/i
  # Pattern used to split head line - used by Wdot.tail .

  # Pattern - node definition. 
  Node_pat = /^\s*(\w+
    # May be followed by optional (dash word)s then a space.
    (?:-\w+)*)\b\s*
    # Must not be followed with ->,--,<- or <-> .
    (?!->|<-|--|<->)
    # Capture group 2 - starting with the " .
    (?:"
      (
    # Followed by anything that is not " or \ .
        (?:[^"\\]*
    # Followed by " or \ .
          (?:["\\])*
        )*
      )"
    # Capture group 2 ending with " .
    )*\s*$/x

  # Pattern - start_node definition eg. _begin
  # The parse pattern is almost the same - just different capture groups.
  Start_node_pat = /^\s*(_(\w+(?:-\w+)*))\b\s*(?!->)(?:(?:"((?:[^"\\]*["\\]*)*)")*)*\s*$/

  # if_node pattern.
  If_node_pat =     /^\s*(if_([-\w]+))\b\s*(?!->)(?:(?:"((?:[^"\\]*["\\]*)*)")*)*\s*$/
  # edge pattern: Node_pat -> Node_pat rest
  #Edge_pat =       /^\s*(\w+[-\w]*\b\s*(?:->)\s*\w+[-\w]*)\b\s*(?!->)(?:(?:"((?:[^"\\]*["\\]*)*)")*)*\s*$/
  # Groups: a->b "title"
  # 1: a->b
  # 2: a
  # 3: ->
  # 4: b
  # 5: title
  Edge_pat =       /^\s*((\w+)[-\w]*\b\s*(->|<-|--|<->)\s*(\w+)[-\w]*)\b\s*(?!->|<-|--|<->)(?:(?:"((?:[^"\\]*["\\]*)*)")*)*\s*$/

  # Split a string delimited by space of comma but
  # keep quoted values together.
  # Wdot.split 'a "b,c"' # -> ['a','"b,c"']
  def Wdot.split(line)
    line.scan Word_pat if line
  end

  # Parse the :head tag
  def Wdot.head_parse(line)
    title = ''
    line.match Head_pat
    if $1.strip != ''
      ret = Wdot.split($1)
      ret.each { |e|
        if e =~ /^"?(TB|BT|RL|LR)"?$/i
          @@rankdir = $1
        #elsif e =~ /^"?([-,\s\w]+)"?$/
        elsif e =~ /^(?:(?:"((?:[^"\\]*["\\]*)*)")*)$/
          title = $1
        end
      }
    end
    parse_string = <<STR
digraph G {
  graph [ label="#{title}", bgcolor="#{@@graph_bgcolor}",
    fontname="#{@@graph_fontname}", rankdir="#{@@rankdir}"]
  node [fontname="#{@@node_fontname}", shape="#{@@node_shape}",
    style="#{@@node_style}", fillcolor="#{@@node_fillcolor}"]
  edge [fontname="#{@@edge_fontname}", color="#{@@edge_color}",
    dir="#{@@edge_dir}"]
STR
  end

  # Parse start nodes eg. _begin or _end .
  def Wdot.start_node_parse(line)
    line.match Start_node_pat
    full_node_name = $1
    node_name = $2
    node_name = $3 if $3
    parse_string = <<STR
#{full_node_name} [label="#{node_name}", shape="#{@@start_node_shape}",
  fillcolor="#{@@start_node_fillcolor}"]
STR
  end

  # Parse a node definition.
  def Wdot.node_parse(line)
    line.match Node_pat
    node_name = $1
    title = $1
    title = $2 if $2
    parse_string = <<ENDSTR
#{node_name} [label="#{title}"]
ENDSTR
  end

  # Parse an edge definition. eg a->b "A to B"
  def Wdot.edge_parse(line)
    line.match Edge_pat
    edge_def=$1
    a = $2
    op = $3 if $3
    b = $4
    title = $5 if $5
    parse_string = ''
    if    op == '<-'
      parse_string = %Q{#{a}->#{b} [label="#{title}" dir="back"]\n}
    elsif op == '--'
      parse_string = %Q{#{a}->#{b} [label="#{title}" dir="none"]\n}
    elsif op == '<->'
      parse_string = %Q{#{a}->#{b} [label="#{title}" dir="both"]\n}
    else # -> case
      parse_string = %Q{#{a}->#{b} [label="#{title}"]\n}
    end
  end

  # Parse an if_node. eg. if_ok
  def Wdot.if_node_parse(line)
    line.match If_node_pat
    node_name=$1
    title = "#{$2}?"
    title = $3 if $3
    parse_string = <<ENDSTR
#{node_name} [label="#{title}",shape="diamond"]
ENDSTR
  end

  # Is line a definition, given pat?
  def Wdot.definition?(pat,line)
    ret = false
    if line.match pat
      ret = true
    end
    return ret
  end

end

#######################################################################
if $0 == __FILE__
  STDIN.each { |line|
    line.chomp!

    # There are esssentially 3 patterns we check for:
    # # Head
    # * Node - Including Start_node, If_node and generic node.
    # * Edge
    # If none of the above match then it is a customized line
    # which we output unchanged.
    if    Wdot.definition?(Wdot::Head_pat,line)
      puts Wdot.head_parse(line)
    
    elsif Wdot.definition?(Wdot::Node_pat,line)
      if Wdot.definition?(Wdot::Start_node_pat,line)
        puts Wdot.start_node_parse(line)
      elsif Wdot.definition?(Wdot::If_node_pat,line)
        puts Wdot.if_node_parse(line)
      else
        puts Wdot.node_parse(line)
      end
    
    elsif Wdot.definition?(Wdot::Edge_pat,line)
      puts Wdot.edge_parse(line)
    
    else
      puts line
    end
  }
end
