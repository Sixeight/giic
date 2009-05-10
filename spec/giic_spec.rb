require File.dirname(__FILE__) + '/spec_helper'

# TODO: need more test code
class Giic

  describe Giic do
    %w[ search list show ].each do |meth|
      instance_eval <<-EOS
        it "has #{meth} method" do
          Giic.instance_methods.should be_include('#{meth}')
        end
      EOS
    end

    describe User do
      %w[
        open close reopen edit label
        comment add_label remove_label
      ].each do |meth|
        instance_eval <<-EOS
          it "has #{meth} method" do
            User.instance_methods.should be_include('#{meth}')
          end
        EOS
      end
    end

    describe Core do
      %w[
        search list show open close
        reopen edit label comment
      ].each do |meth|
        instance_eval <<-EOS
          it "ihas #{meth} method" do
            Core.should respond_to :#{meth}
          end
        EOS
      end
    end
  end
end

