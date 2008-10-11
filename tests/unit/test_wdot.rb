#! /usr/bin/ruby
require 'test/unit'
require File.dirname(__FILE__)+'/../../wdot.rb'

class TestWdot < Test::Unit::TestCase
  #def setup
  #end
  #def teardown
  #end
  def test_split
    assert_equal ['a','"b,c"'], Wdot.split('a "b,c"')
  end
  def test_head?
    assert_equal true, Wdot.definition?(Wdot::Head_pat,':head'), 't1'
    assert_equal false, Wdot.definition?(Wdot::Head_pat,':heady '), 't2'
    assert_equal true, Wdot.definition?(Wdot::Head_pat,':head a b c'), 't3'
    assert_equal true, Wdot.definition?(Wdot::Head_pat,':HeAd a b c'), 't4'
  end
  # The following test is order-sensitive as it sets Wdot::@@rankdir
  def test_head_parse
    expected2 = <<END
digraph G {
  graph [ label="", bgcolor="white",
    fontname="Arial", rankdir="TB"]
  node [fontname="Arial", shape="box",
    style="filled", fillcolor="AliceBlue"]
  edge [fontname="Arial", color="Blue",
    dir="forward"]
END
    assert_equal expected2, Wdot.head_parse(':head {'), 't2'

    expected1 = <<END
digraph G {
  graph [ label="My Title", bgcolor="white",
    fontname="Arial", rankdir="LR"]
  node [fontname="Arial", shape="box",
    style="filled", fillcolor="AliceBlue"]
  edge [fontname="Arial", color="Blue",
    dir="forward"]
END
    assert_equal expected1, Wdot.head_parse(':head "My Title" LR {'), 't1'
    assert_equal expected1, Wdot.head_parse(':head LR "My Title" {'), 't3'
    assert_equal expected1, Wdot.head_parse(':head "LR" "My Title" {'), 't4'
    assert_equal expected1, Wdot.head_parse(':head "LR", "My Title" {'), 't5'
    assert_equal expected1, Wdot.head_parse(':head LR,"My Title"{'), 't6'

    expected3 = <<END
digraph G {
  graph [ label="", bgcolor="white",
    fontname="Arial", rankdir="LR"]
  node [fontname="Arial", shape="box",
    style="filled", fillcolor="AliceBlue"]
  edge [fontname="Arial", color="Blue",
    dir="forward"]
END
    assert_equal expected3, Wdot.head_parse(':head LR {'), 't7'

    expected4 = <<END
digraph G {
  graph [ label="with (brackets)", bgcolor="white",
    fontname="Arial", rankdir="LR"]
  node [fontname="Arial", shape="box",
    style="filled", fillcolor="AliceBlue"]
  edge [fontname="Arial", color="Blue",
    dir="forward"]
END
    assert_equal expected4, Wdot.head_parse(':head "with (brackets)", LR {'), 't7'
  end
  
  def test_node_def?
    assert_equal true, Wdot.definition?(Wdot::Node_pat,
      '  _start-node "Start Node"'), 't1'
    assert_equal false, Wdot.definition?(Wdot::Node_pat,
      '  _start-node -> _end "edge-name"') , 't2'
    assert_equal false, Wdot.definition?(Wdot::Node_pat,
      '_start-node->_end') , 't3'
    assert_equal false, Wdot.definition?(Wdot::Node_pat,
      '-start-node') , 't4'
    assert_equal false, Wdot.definition?(Wdot::Node_pat,
      'a [') , 't5'
    assert_equal true, Wdot.definition?(Wdot::Node_pat,
      'aes_3 "[aes->3]"') , 't6'
    assert_equal true, Wdot.definition?(Wdot::Node_pat,
      'aes_3 "[aes->\"3\"]"') , 't7'
  end
  def test_start_node_def?
    assert_equal true, Wdot.definition?(Wdot::Start_node_pat,
      '  _start-node "Start->Node"') , 't1'
    assert_equal false, Wdot.definition?(Wdot::Start_node_pat,
      '  _start-node->end "Finish"') , 't2'
    assert_equal false, Wdot.definition?(Wdot::Start_node_pat,
      '_-start-node') , 't3'
    assert_equal false, Wdot.definition?(Wdot::Start_node_pat,
      '_start [label="my label"]') , 't4'
    assert_equal true, Wdot.definition?(Wdot::Start_node_pat,
      '_start') , 't5'
    assert_equal false, Wdot.definition?(Wdot::Start_node_pat,
      '_start abc') , 't6'
    assert_equal false, Wdot.definition?(Wdot::Start_node_pat,
      '_s [') , 't7'
  end
  def test_definition?
    assert_equal true, Wdot.definition?(Wdot::Word_pat,'abcd'),'t1'
    assert_equal false, Wdot.definition?(Wdot::Word_pat,','),'t2'
    assert_equal false, Wdot.definition?(Wdot::Word_pat,' '),'t3'
    assert_equal false, Wdot.definition?(Wdot::Word_pat,'->'),'t4'
  end
  def test_if_node_def?
    assert_equal true, Wdot.definition?(Wdot::If_node_pat,
      'if_working'), 't1'
    assert_equal true, Wdot.definition?(Wdot::If_node_pat,
      '  if_working "Working?" '), 't2'

    str = '  if_working->fail "Working?" '
    assert_equal false, 
      Wdot.definition?(Wdot::If_node_pat, str)\
      && Wdot.definition?(Wdot::Node_pat, str), 't3'
    
    assert_equal true, Wdot.definition?(Wdot::If_node_pat,
      'if_-a "negative A"'), 't4'
    assert_equal false, Wdot.definition?(Wdot::If_node_pat,
      'if_- "negative val"'), 't5'

    str = 'if_a ['
    assert_equal false, 
      Wdot.definition?(Wdot::If_node_pat, str)\
      && Wdot.definition?(Wdot::Node_pat, str), 't6'
    
    assert_equal true, Wdot.definition?(Wdot::If_node_pat,
      '  if_working "(Working?)" '), 't2'
  end
  def test_edge_def?
    assert_equal true, Wdot.definition?(Wdot::Edge_pat,
      'a->b'), 't1'
    assert_equal false, Wdot.definition?(Wdot::Edge_pat,
      'a'), 't2'
    assert_equal true, Wdot.definition?(Wdot::Edge_pat,
      'a -> b "something"'), 't3'
    assert_equal true, Wdot.definition?(Wdot::Edge_pat,
      'a->b "something"'), 't4'
    assert_equal false, Wdot.definition?(Wdot::Edge_pat,
      'a->b ["something"]'), 't5'
  end
  def test_start_node_parse
    str1 = <<ENDSTR
_start [label="start", shape="circle",
  fillcolor="LightPink"]
ENDSTR
    assert_equal str1, Wdot.start_node_parse('_start'), 't1'
    str2 = <<ENDSTR
_start [label="Begin \\"here\\"", shape="circle",
  fillcolor="LightPink"]
ENDSTR
    assert_equal str2, Wdot.start_node_parse('_start "Begin \"here\""'), 't2'
  end
  def test_node_parse
    assert_equal "a [label=\"\\\"A\\\"-node\"]\n", Wdot.node_parse('a "\"A\"-node"'), 't1'
    assert_equal "a [label=\"a\"]\n", Wdot.node_parse('a'), 't2'
    assert_equal "a [label=\"a\"]\n", Wdot.node_parse(' a  '), 't3'
  end
  def test_edge_parse
    assert_equal "a->b [label=\"A to B\"]\n", Wdot.edge_parse('a->b "A to B"'), 't1'
    assert_equal "a->b [label=\"\"]\n", Wdot.edge_parse('a->b'), 't2'
    assert_equal "a->b [label=\"A to \\\"B\\\"\"]\n", Wdot.edge_parse('a->b "A to \"B\""'), 't3'
  end
  def test_if_node_parse
    assert_equal "if_ok [label=\"ok?\",shape=\"diamond\"]\n", Wdot.if_node_parse('if_ok'), 't1'
    assert_equal "if_ok [label=\"ok?\",shape=\"diamond\"]\n", Wdot.if_node_parse('if_ok '), 't2'
    assert_equal "if_ok [label=\"Good ?\",shape=\"diamond\"]\n", Wdot.if_node_parse('if_ok "Good ?"'), 't3'
    assert_equal "if_ok [label=\"\\\"Good\\\" ?\",shape=\"diamond\"]\n", Wdot.if_node_parse('if_ok "\"Good\" ?"'), 't4'
  end
end
