#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'typhoeus'
require 'yaml'

class Giic
  attr_reader :user, :repo

  def initialize(user, repo)
    @user, @repo = user, repo
  end

  def search(query, state = 'open')
    Core.search :user => @user, :repo => @repo, :state => state, :search_term => query
  end

  def list(state = 'open')
    Core.list :user => @user, :repo => @repo, :state => state
  end

  def show(number)
    Core.show :user => @user, :repo => @repo, :number => number
  end

  def login(login = nil, token = nil)
    unless [login, token].all?
      raise 'You must login at least onece' unless @login_user
      return @login_user
    end
    User.new login, token, self
  end

  def login!(login, token)
    @login_user = login(login, token)
  end

  class User
    def initialize(login, token, project)
      @login, @token = login, token
      @project = project
    end

    def open(title, body)
      Giic::Core.open(:user => @project.user, :repo => @project.repo,
                     :params => { :title => title, :body => body }.merge(authentication_data))
    end

    def close(number)
      Giic::Core.close(:user => @project.user, :repo => @project.repo, :number => number,
                      :params => authentication_data)
    end

    def reopen(number)
      Giic::Core.reopen(:user => @project.user, :repo => @project.repo, :number => number,
                       :params => authentication_data)
    end

    def edit(number, body, title = nil)
      edit_data = { :body => body }
      edit_data.merge!(:title => title) if title
      Giic::Core.edit(:user => @project.user, :repo => @project.repo, :number => number,
                     :params => edit_data.merge(authentication_data))
    end

    def label(operate, number, label)
      Giic::Core.label(:user => @project.user, :repo => @project.repo, :number => number,
                      :operate => operate, :label => label,
                      :params => authentication_data)
    end

    def add_label(number, label)
      label 'add', number, label
    end

    def remove_label(number, label)
      label 'remove', number, label
    end

    def comment(comment)
      Giic::Core.commebt(:user => @project.user, :repo => @project.repo, :number => number,
                        :params => { :comment => comment }.merge(authentication_data))
    end

    def change_project(project)
      raise 'project must be instance of Giic'  unless project.instance_of? Giic
      @project = project
    end

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

    def authentication_data
      { :login => @login, :token => @token }
    end
  end

  class Core
    include Typhoeus
    remote_defaults :base_uri   => 'http://github.com/api/v2/yaml/issues',
                    :on_success => lambda {|responce| YAML.load(responce.body) },
                    :on_failure => lambda {|responce| warn "Error occured: #{responce.code}" }

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

