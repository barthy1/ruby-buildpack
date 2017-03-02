require 'cf_spec_helper'

describe LanguagePack::NodeInstaller do
  describe '#install' do
    context 'with different stacks' do
      let(:installer) { LanguagePack::NodeInstaller.new('stack') }

      before do
        allow(FileUtils).to receive(:mv)
        allow(FileUtils).to receive(:rm_rf)
        allow_any_instance_of(LanguagePack::Fetcher).to receive(:fetch_untar)
      end

      it 'always executes the modern Fetcher' do
        node_tar_regex = Regexp.new('node\-v\d+\.\d+\.\d+' + Regexp.quote("-linux-{platform}.tar.gz"))
        extract_path_regex = Regexp.new('node\-v\d+\.\d+\.\d+' + Regexp.quote("-linux-{platform}/bin/node"))
        expect_any_instance_of(LanguagePack::Fetcher).to receive(:fetch_untar).
          with(node_tar_regex, extract_path_regex)
        installer.install
      end

      it 'moves the node binary to the current path' do
        extract_path_regex = Regexp.new('node\-v\d+\.\d+\.\d+' + Regexp.quote("-linux-{platform}/bin/node"))
        expect(FileUtils).to receive(:mv).with(extract_path_regex, '.')
        installer.install
      end
    end
  end

  def platform
    platform_map = { 'x86_64' => 'x64',
                     'powerpc64le' => 'ppc64le'}
    platform_map[arch]
  end

  def arch
    RbConfig::CONFIG['host_cpu']
  end
end
