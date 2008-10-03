#! /usr/bin/ruby
require 'test/unit'
require 'fileutils'
#require File.dirname(__FILE__)+'/../../wdot.rb'
$wdot_pgm = File.dirname(__FILE__)+'/../../wdot.rb'
$testdir = File.dirname(__FILE__)
$wdot_pgm = $testdir+'/../../wdot.rb'

class TestWdot < Test::Unit::TestCase
  def setup
    FileUtils.mkdir($testdir+'/output') unless File.exists?($testdir+'/output')
  end
  def teardown
    FileUtils.rm_rf($testdir+'/output', :secure => true)
  end
  def test_simple
    assert system( %Q{#{$wdot_pgm} < #{$testdir}/input/simple.wdot > #{$testdir}/output/simple.dot }), 't1'
    assert system( "cmp #{$testdir}/output/simple.dot #{$testdir}/expected/simple.dot"), 't2'
  end
  def test_intermediate
    assert system( %Q{#{$wdot_pgm} < #{$testdir}/input/intermediate.wdot > #{$testdir}/output/intermediate.dot }), 't1'
    assert system( "cmp #{$testdir}/output/intermediate.dot #{$testdir}/expected/intermediate.dot"), 't2'
  end
  def test_complex
    assert system( %Q{#{$wdot_pgm} < #{$testdir}/input/complex.wdot > #{$testdir}/output/complex.dot }), 't1'
    assert system( "cmp #{$testdir}/output/complex.dot #{$testdir}/expected/complex.dot"), 't2'
  end
end
