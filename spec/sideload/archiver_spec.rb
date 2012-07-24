require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Sideload::Archiver do
  describe "#new" do
    it "should create the repository directory" do
      archiver = Sideload::Archiver.new('ssh://enterprise-example', 'test', 'test')
      archiver.repodir.parent.should exist
    end

    it "should create the archive directory" do
      archiver = Sideload::Archiver.new('ssh://enterprise-example', 'test', 'test')
      File.exist?(archiver.archivedir).should be_true
    end

    it "should set the repodir" do
      archiver = Sideload::Archiver.new('ssh://enterprise-example', 'test', 'test')
      archiver.repodir.to_s.should =~ %r{tmp/git/test/test.git}
    end
  end

  describe "#archive" do
    it "should save a tar file to the archive directory" do
      archiver = Sideload::Archiver.new('git://github.com', 'vertis', 'sideload')
      archiver.archive
      File.exist?(archiver.archivefile).should be_true
    end

    it "should return the path of the archive" do
      archiver = Sideload::Archiver.new('git://github.com', 'vertis', 'flynn')
      archiver.archive('081178062d').to_s.should =~ %r{/tmp/git-tars/vertis-flynn-081178062d}
    end
  end
end