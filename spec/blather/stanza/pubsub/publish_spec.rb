require 'spec_helper'
require 'fixtures/pubsub'

describe Blather::Stanza::PubSub::Publish do
  it 'registers itself' do
    Blather::XMPPNode.class_from_registration(:publish, 'http://jabber.org/protocol/pubsub').should == Blather::Stanza::PubSub::Publish
  end

  it 'can be imported' do
    Blather::XMPPNode.parse(publish_xml).should be_instance_of Blather::Stanza::PubSub::Publish
  end

  it 'ensures an publish node is present on create' do
    publish = Blather::Stanza::PubSub::Publish.new
    publish.xpath('//ns:pubsub/ns:publish', :ns => Blather::Stanza::PubSub.registered_ns).should_not be_empty
  end

  it 'ensures an publish node exists when calling #publish' do
    publish = Blather::Stanza::PubSub::Publish.new
    publish.pubsub.remove_children :publish
    publish.xpath('//ns:pubsub/ns:publish', :ns => Blather::Stanza::PubSub.registered_ns).should be_empty

    publish.publish.should_not be_nil
    publish.xpath('//ns:pubsub/ns:publish', :ns => Blather::Stanza::PubSub.registered_ns).should_not be_empty
  end

  it 'defaults to a set node' do
    publish = Blather::Stanza::PubSub::Publish.new
    publish.type.should == :set
  end

  it 'sets the host if requested' do
    publish = Blather::Stanza::PubSub::Publish.new 'pubsub.jabber.local'
    publish.to.should == Blather::JID.new('pubsub.jabber.local')
  end

  it 'sets the node' do
    publish = Blather::Stanza::PubSub::Publish.new 'host', 'node-name'
    publish.node.should == 'node-name'
  end

  it 'will iterate over each item' do
    publish = Blather::Stanza::PubSub::Publish.new.inherit parse_stanza(publish_xml).root
    count = 0
    publish.each do |i|
      i.should be_instance_of Blather::Stanza::PubSub::PubSubItem
      count += 1
    end
    count.should == 1
  end

  it 'has a node attribute' do
    publish = Blather::Stanza::PubSub::Publish.new
    publish.should respond_to :node
    publish.node.should be_nil
    publish.node = 'node-name'
    publish.node.should == 'node-name'
    publish.xpath('//ns:publish[@node="node-name"]', :ns => Blather::Stanza::PubSub.registered_ns).should_not be_empty
  end

  it 'can set the payload with a hash' do
    payload = {'id1' => 'payload1', 'id2' => 'payload2'}
    publish = Blather::Stanza::PubSub::Publish.new
    publish.payload = payload
    publish.size.should == 2
    publish.xpath('/iq/ns:pubsub/ns:publish[ns:item[@id="id1" and .="payload1"] and ns:item[@id="id2" and .="payload2"]]', :ns => Blather::Stanza::PubSub.registered_ns).should_not be_empty
  end

  it 'can set the payload with an array' do
    payload = %w[payload1 payload2]
    publish = Blather::Stanza::PubSub::Publish.new
    publish.payload = payload
    publish.size.should == 2
    publish.xpath('/iq/ns:pubsub/ns:publish[ns:item[.="payload1"] and ns:item[.="payload2"]]', :ns => Blather::Stanza::PubSub.registered_ns).should_not be_empty
  end

  it 'can set the payload with a string' do
    publish = Blather::Stanza::PubSub::Publish.new
    publish.payload = 'payload'
    publish.size.should == 1
    publish.xpath('/iq/ns:pubsub/ns:publish[ns:item[.="payload"]]', :ns => Blather::Stanza::PubSub.registered_ns).should_not be_empty
  end
end
