# -*- coding: utf-8 -*-

require 'net/ping' #ping
require 'net/ssh' #ssh


class PCnode
	attr_accessor :node_num, :addr, :node_num_str,:ssh,:status
	def initialize(num,timeout:1,ssh:nil)
		@node_num = num
		@ssh      = ssh

		case @node_num.to_s.size
			when 1
				@node_num_str = '00'+ @node_num.to_s
			when 2
				@node_num_str = '0' + @node_num.to_s
			else
				raise SyntaxError.new('invalid node_num')
		end
		@addr = "esys-pc#{@node_num_str}.edu.esys.tsukuba.ac.jp"
		@pinger = Net::Ping::External.new(@addr,nil,timeout)
		@ssh[:opt][:timeout]=timeout if ssh
	end

	def on?
		return @pinger.ping?
	end

	def linux?
		if ssh.nil?
			raise SyntaxError.new('no ssh option')
		end

		begin
			return true if Net::SSH.start(@addr,ssh[:username],ssh[:opt])
		rescue
			return false
		end
	end

	def windows?
		return !self.linux? && self.on?
	end

	def get_status
		#status = :Linux :windows :off
		if @ssh
			@status ||= :linux if self.linux?
			@status ||= :windows if self.on?
		else
			@status ||= :on if self.on?
		end
		@status ||= :off
		return @status
	end
end


class PCroom
	attr_accessor :nodeList,:responseList,:status

	def initialize(range=2..91,timeout:1,ssh:nil)
		raise SyntaxError.new('invalid range') unless range.is_a? Range

		@on_count=0; @nodeList=[]; @responseList=[];
		range.each do |num|
			@nodeList << PCnode.new(num,timeout:timeout,ssh:ssh)
		end
	end

	def get_status()
		threads = []
		@nodeList.each_with_index do |node,i|
			threads << Thread.new{
				@responseList[i] = node.get_status
			}
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

