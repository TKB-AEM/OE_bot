# coding: utf-8

module OEbot
  class PCroom

    attr_accessor :nodeList, :responseList, :status

    def initialize(range=2..91, timeout:1, ssh:nil)
      raise "invalid range" unless range.is_a? Range
      @on_count=0; @nodeList=[]; @responseList=[];
      range.each do |num|
        @nodeList << OEbot::PCnode.new(num, timeout:timeout, ssh:ssh)
      end
    end

    def get_status()
      threads = []
      @nodeList.each_with_index do |node, i|
        threads << Thread.new do
          @responseList[i] = node.get_status
        end
      end
      threads.each{|job| job.join}
      @status = responseList
      return responseList
    end

    def count(symbol) #tag = :linux or :windows or :off
      @status ||= self.get_status()
      counter = 0
      @status.each{|node| counter+=1 if node==symbol}
      return counter
    end
  end
end
