require 'thread'

class Gem::Mirror::Pool
  def initialize(size)
    @size = size
    @queue = Queue.new
  end

  def job(&blk)
    @queue << blk
  end

  def run_til_done
    threads = Array.new(@size) do
      Thread.new { @queue.pop.call while true }
    end
    until @queue.empty? && @queue.num_waiting == @size
      threads.each { |t| t.join(0.1) }
    end
    threads.each { |t| t.kill }
  end
end
