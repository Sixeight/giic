#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

#
# == Giic
#
# Giic is a client of the github-issues API interface.
#

require 'rubygems'
require 'typhoeus'
require 'yaml'

# TODO: must find a better way to get same result
class Hash # :nodoc:
  module CoreExt # :nodoc
    def method_missing(meth, *args)
      if value = self[meth] || self[meth.to_s]
        return value
      end
      super
    end
  end
  include CoreExt
end

class Giic

  VERSION = '0.0.2'

  attr_reader :user, :repo

  class APIError < Exception
    attr_reader :responce, :backtrace
    def initialize(responce, backtrace)
      @responce, @backtrace = responce, backtrace
      super responce['error'].first['error']
    end
    def inspect; message end
  end

  def initialize(user, repo)
    @user, @repo = user, repo
  end

  # search issue
  # #=> issues
  def search(query, state = 'open')
    Core.search(:user => @user, :repo => @repo, :state => state, :search_term => query)
  end

  # list issues
  # #=> issues
  def list(state = 'open')
    Core.list(:user => @user, :repo => @repo, :state => state)
  end

  # show specific issue
  # #=> issue
  def show(number)
    Core.show(:user => @user, :repo => @repo, :number => number)
  end

  # get user instance for POST request
  # #=> Instance of Giic::User
  def login(login = nil, token = nil)
    unless [login, token].all?
      raise 'You must login at least onece' unless @login_user
      return @login_user
    end
    User.new login, token, self
  end

  # login github
  def login!(login, token)
    @login_user = login(login, token)
  end

  # take values or error from responce
  def self.take(default, result)
    if result.has_key? 'error'
      raise APIError.new(result, caller)
    end
    result[default.to_s]
  end

  class User
    def initialize(login, token, project)
      @login, @token = login, token
      @project = project
    end

    # open new issue
    # #=> issue
    def open(title, body)
      Giic::Core.open(:user => @project.user, :repo => @project.repo,
                                   :params => { :title => title, :body => body }.merge(authentication_data))
    end

    # close issue
    # #=> issue
    def close(number)
      Giic::Core.close(:user => @project.user, :repo => @project.repo, :number => number,
                                    :params => authentication_data)
    end

    # reopen issue
    # #=> issue
    def reopen(number)
      Giic::Core.reopen(:user => @project.user, :repo => @project.repo, :number => number,
                                     :params => authentication_data)
    end

    # edit issue
    # #=> issue
    def edit(number, body, title = nil)
      edit_data = { :body => body }
      edit_data.merge!(:title => title) if title
      Giic::Core.edit(:user => @project.user, :repo => @project.repo, :number => number,
                                   :params => edit_data.merge(authentication_data))
    end

    # to operate label for issue
    # #=> labels
    def label(operate, label, number)
      Giic::Core.label(:user => @project.user, :repo => @project.repo, :number => number,
                                     :operate => operate, :label => label,
                                     :params => authentication_data)
    end

    # add label to issue
    # #=> labels
    def add_label(label, number)
      label 'add', label, number
    end

    # remove label from issue
    # #=> labels
    def remove_label(label, number)
      label 'remove', label, number
    end

    # post comment to issue
    # #=> comment
    def comment(number, comment)
      Giic::Core.comment(:user => @project.user, :repo => @project.repo, :number => number,
                                         :params => { :comment => comment }.merge(authentication_data))
    end

    def change_project!(project)
      raise 'project must be instance of Giic'  unless project.instance_of? Giic
      @project = project
    end

    # swap using project temporarily. e.g.)
    #
    #  proj.login.with_project({:repo => 'other'}) do |user|
    #    user.open('new issue', 'I have a lot of bugs')
    #  end
    def with_project(project)
      original = @project
      @project = case project
        when Giic
          project
        when Hash
          user = project[:user] || original.user
          repo = project[:repo] || original.repo
          Giic.new user, repo
        else
          raise 'project must be instance of Giic or Hash'
        end
      yield self
    ensure
      @project = original
    end

    private

    def authentication_data # :nodoc:
      { :login => @login, :token => @token }
    end
  end

  # Core class is the Giic core that using Typhoeus library
  class Core
    include Typhoeus
    remote_defaults :base_uri   => 'http://github.com/api/v2/yaml/issues',
                    :on_success => lambda {|responce| YAML.load(responce.body) },
                    :on_failure => lambda {|responce| { 'error' => { 'error'    => 'connection error',
                                                                     'responce' => responce,
                                                                     'code'     => responce.code }}}

    define_remote_method :search,  :path => '/search/:user/:repo/:state/:search_term'
    define_remote_method :list,    :path => '/list/:user/:repo/:state'
    define_remote_method :show,    :path => '/show/:user/:repo/:number'
    define_remote_method :open,    :path => '/open/:user/:repo',                          :method => 'post'
    define_remote_method :close,   :path => '/close/:user/:repo/:number',                 :method => 'post'
    define_remote_method :reopen,  :path => '/reopen/:user/:repo/:number',                :method => 'post'
    define_remote_method :edit,    :path => '/edit/:user/:repo/:number',                  :method => 'post'
    define_remote_method :label,   :path => '/label/:operate/:user/:repo/:label/:number', :method => 'post'
    define_remote_method :comment, :path => '/comment/:user/:repo/:number',               :method => 'post'
  end
end

