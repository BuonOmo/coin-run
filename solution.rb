#!/usr/bin/env ruby
# frozen_string_literal: true

verbose = !ENV["VERBOSE"].nil?

def color(string, index, color, persist = false)
    color = { "blue" => 34, "green" => 32 }[color]
    string = string.dup unless persist
    string[index] = "\e[#{color}m#{string[index]}\e[0m"
    string
end

class Candidate
    include Comparable

    attr_reader :pos
    attr_reader :diff

    def initialize(pos, diff)
        @sorter = diff.abs
        @pos = pos
        @diff = diff
    end

    def inspect
        "<#@pos #@diff (#{valid? ? to_s : "-"})>"
    end

    def <=>(other)
        return nil unless other.is_a? Candidate

        @sorter <=> other.instance_variable_get(:@sorter)
    end

    def valid?
        !to_s.nil?
    end

    def to_s
        { 1 => "Right", -1 => "Left", 0 => "Down" }[@diff]
    end
end

gets

input = ""
message = nil
before_lines = []
until input[?V]
    input = gets.chomp
    before_lines << input
end
before_lines.pop

pos = input.index ?V
prev = nil
size = input.size
inputs = [input]
after_lines = $<.map(&:chomp)
while !after_lines.empty?
    input = after_lines.shift
    break unless input[?O]

    inputs << input
    candidates = input.chars.map.with_index do |char, new_pos|
        next unless char == ?O
        diff = ((new_pos - pos) % size + 2) % size - 2
        Candidate.new(new_pos, diff)
    end.compact
    current = candidates.min
    break unless current.valid?
    prev, pos = pos, current.pos

    puts current

    next unless verbose
    if message
        sleep 0.2
        STDERR.print "\e[#{message.count("\n")}A\e[J"
    end
    array = [
        *before_lines,
        *inputs[0..-3],
        color(inputs[-2], prev, "green", true),
        color(inputs[-1], pos, "blue"),
        *after_lines
    ]
    message = <<~TEXT

    #{array * "\n"}

    candidates: #{candidates.first(5)}
    chosen: #{current.inspect}


    TEXT
    STDERR.print message
end
