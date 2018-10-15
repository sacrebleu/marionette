# frozen_string_literal: true

# require_relative "../app/models/parser/core"

RSpec.describe 'ManifestRun' do
  let(:v3_logs) do
    <<~DOC
      2018-01-01 13:21:40 +0000 Creating a new SSL key for rspec.ci
      2018-01-01 13:22:40 +0000 line 1
      2018-01-01 13:23:40 +0000 line 2
      2018-01-01 13:24:40 +0000 line 3
      2018-01-01 13:25:40 +0000 npe-apt-update-cache executed successfully
      2018-01-01 13:35:40 +0000 Unscheduling refresh on Service[rspec-puppet-v3]
      2018-01-01 13:39:40 +0000 Puppet (notice): Finished catalog run in
    DOC
      .split("\n")
  end

  let(:v6_logs) do
    <<~DOC
      2018-01-01 13:21:40 +0000 Creating a new SSL key for rspec.ci
      2018-01-01 13:22:40 +0000 line 1
      2018-01-01 13:23:40 +0000 line 2
      2018-01-01 13:24:40 +0000 line 3
      2018-01-01 13:25:40 +0000 npe-apt-update-cache executed successfully
      2018-01-01 13:35:40 +0000 Unscheduling refresh on Service[rspec-puppet-v3]
      2018-01-01 13:39:40 +0000 Puppet (notice): Applied catalog in
    DOC
      .split("\n")
  end

  let(:v6_multientry_logs) do
    <<~DOC
      2018-01-01 13:21:40 +0000 Creating a new SSL key for rspec.ci
      2018-01-01 13:22:40 +0000 line 1
      2018-01-01 13:23:40 +0000 line 2
      2018-01-01 13:24:40 +0000 line 3
      2018-01-01 13:25:40 +0000 npe-apt-update-cache executed successfully
      2018-01-01 13:35:40 +0000 Unscheduling refresh on Service[rspec-dummy-2]
      2018-01-01 13:45:40 +0000 Unscheduling refresh on Service[rspec-dummy-3]
      2018-01-01 13:55:40 +0000 Unscheduling refresh on Service[rspec-dummy-4]
      2018-01-01 14:05:40 +0000 Unscheduling refresh on Service[rspec-dummy-5]
      2018-01-01 14:08:40 +0000 Puppet (notice): Applied catalog in
    DOC
      .split("\n")
  end

  let(:v6_multientry_revisit_logs) do
    <<~DOC
      2018-01-01 13:21:40 +0000 Creating a new SSL key for rspec.ci
      2018-01-01 13:22:40 +0000 line 1
      2018-01-01 13:23:40 +0000 line 2
      2018-01-01 13:24:40 +0000 line 3
      2018-01-01 13:25:40 +0000 npe-apt-update-cache executed successfully
      2018-01-01 13:35:40 +0000 Unscheduling refresh on Service[rspec-dummy-2]
      2018-01-01 13:45:40 +0000 Unscheduling refresh on Service[rspec-dummy-3]
      2018-01-01 13:55:40 +0000 Unscheduling refresh on Service[rspec-dummy-4]
      2018-01-01 14:06:40 +0000 Unscheduling refresh on Service[rspec-dummy-3]
      2018-01-01 14:07:40 +0000 Unscheduling refresh on Service[rspec-dummy-5]
      2018-01-01 14:08:40 +0000 Puppet (notice): Applied catalog in
    DOC
      .split("\n")
  end

  let(:default) do
    x = ManifestRun.new(v6_logs)
    x.parse!
    x
  end

  let(:multientry) {
    x = ManifestRun.new(v6_multientry_logs)
    x.parse!
    x
  }

  let(:multi_rerun) {
    x = ManifestRun.new(v6_multientry_revisit_logs, merge_similar: '0')
    x.parse!
    x
  }

  let(:merged_rerun) {
    x = ManifestRun.new(v6_multientry_revisit_logs, merge_similar: '1')
    x.parse!
    x
  }

  it 'Creates a v6 puppet parser by default' do
    manifest = ManifestRun.new(v6_logs)

    # pp manifest.inspect

    expect(manifest.parser).to be_a(Parser::Puppet6Parser)
  end

  it 'Createes a v3 puppet parser when informed to' do
    manifest = ManifestRun.new(v6_logs, version: :v3)

    expect(manifest.parser).to be_a(Parser::Puppet3Parser)
  end

  it 'Creates a v6 puppet parser if passed nonsense args' do
    manifest = ManifestRun.new(v6_logs, version: :balls)

    expect(manifest.parser).to be_a(Parser::Puppet6Parser)
  end

  it 'Generates a valid title from the log files' do
    expect(default.title).to eql('Provisioning rspec.ci')
  end

  it 'Correctly identifies the puppet start time from the logs' do
    expect(default.starttime.to_s).to eql('2018-01-01 13:21:40 +0000')
  end

  it 'Correctly identifiees the puppet run end time from the logs' do
    expect(default.endtime.to_s). to eql('2018-01-01 13:39:40 +0000')
  end

  it 'Generates a valid subtitle from the log files' do
    expect(default.subtitle).to eql('Puppet run started 2018-01-01 13:21:40 duration: 1080.0s')
  end

  it 'Supplies the domain of the run' do
    expect(default.domain).to eql(['rspec-puppet-v3'])
  end

  it 'Supplies the range of the run' do
    expect(default.range).to eql([0.0])
  end

  it 'Reports the correct domain and range for a multientry run' do 
    expect(multientry.domain.sort).to eql(['rspec-dummy-2', 'rspec-dummy-3', 'rspec-dummy-4', 'rspec-dummy-5'])
    expect(multientry.range).to eql([0.0, 0.3333, 0.6666, 0.9999])
  end

  it 'Reports the correct domain and range for a multi_rerun' do 
    expect(multi_rerun.domain.sort).to eql(['rspec-dummy-2', 'rspec-dummy-3', 'rspec-dummy-3', 'rspec-dummy-4', 'rspec-dummy-5'])
    expect(multi_rerun.range).to eql([0.0, 0.25, 0.5, 0.75, 1.0])
  end

  it 'Reports the correct domain and range for a multi_rerun with merged values' do 
    expect(merged_rerun.domain.sort).to eql(['rspec-dummy-2', 'rspec-dummy-3', 'rspec-dummy-4', 'rspec-dummy-5'])
    expect(multientry.range).to eql([0.0, 0.3333, 0.6666, 0.9999])
  end

end
