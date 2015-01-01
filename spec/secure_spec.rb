describe WatchList::Secure do
  let(:obj) do
    Class.new {
      include WatchList::Secure

      def method_missing(method_name, *args, &block)
        send(method_name, *args, &block)
      end
    }.new
  end

  let(:data) { '*secret data*' }
  let(:pass) { '**secret password**' }
  let(:salt) { 'nU0+G1icf70=' }
  let(:encrypted_data) { 'S2aPj2Ajk11sowGJnV+00Q==' }

  describe '#git_encrypt' do
    before do
      system(%!git config watch-list.pass "#{pass}"!)
      system(%!git config watch-list.salt "#{salt}"!)
    end

    it do
      expect(obj.git_encrypt(data)).to eq(secure: encrypted_data)
    end

    after do
      system('git config --remove-section watch-list')
    end
  end

  describe '#git_decrypt' do
    before do
      system(%!git config watch-list.pass "#{pass}"!)
      system(%!git config watch-list.salt "#{salt}"!)
    end

    it do
      expect(obj.git_decrypt(secure: encrypted_data)).to eq data
    end

    after do
      system('git config --remove-section watch-list')
    end
  end

  describe '#encrypt' do
    it do
      expect(obj.encrypt(pass, salt, data)).to eq encrypted_data
    end
  end

  describe '#decrypt' do
    it do
      expect(obj.decrypt(pass, salt, encrypted_data)).to eq data
    end
  end

  describe '#git_encryptable?' do
    context 'when config is set' do
      before do
        system(%!git config watch-list.pass "#{pass}"!)
        system(%!git config watch-list.salt "#{salt}"!)
      end

      it do
        expect(obj.git_encryptable?).to be_truthy
      end

      after do
        system('git config --remove-section watch-list')
      end
    end

    context 'when config is not set' do
      it do
        expect(obj.git_encryptable?).to be_falsey
      end
    end
  end

  describe '#encrypted_value?' do
    it do
      expect(obj.encrypted_value?(secure: nil)).to be_truthy
    end

    it do
      expect(obj.encrypted_value?(nil)).to be_falsey
    end
  end
end
