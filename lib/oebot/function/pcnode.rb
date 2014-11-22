# coding: utf-8

module OEbot
  class PCnode

    attr_accessor :node_num, :addr, :node_num_str, :ssh, :status

    def initialize(num, timeout:1, ssh:nil)
      @node_num = num
      @ssh      = ssh

      case @node_num.to_s.size
        when 1 then @node_num_str = '00' + @node_num.to_s
        when 2 then @node_num_str = '0'  + @node_num.to_s
        else raise "invalid node_num"
      end
      @addr = "esys-pc#{@node_num_str}.edu.esys.tsukuba.ac.jp"
      @pinger = Net::Ping::External.new(@addr, nil, timeout)
      @ssh[:opt][:timeout]=timeout if ssh
    end

    def on?
      return @pinger.ping?
    end

    def linux?
      raise SyntaxError.new('no ssh option') if ssh.nil?
      return true if Net::SSH.start(@addr, ssh[:username], ssh[:opt])
    rescue
      return false
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
end
