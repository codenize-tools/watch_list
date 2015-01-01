module WatchList::Secure
  CIPHER_NAME = 'AES-256-CBC'

  def git_encrypt(data)
    pass, salt = get_pass_salt_from_git(:validate => true)
    {:secure => encrypt(pass, salt, data)}
  end

  def git_decrypt(data)
    pass, salt = get_pass_salt_from_git(:validate => true)
    decrypt(pass, salt, data.fetch(:secure))
  end

  def encrypt(pass, salt, data)
    cipher = OpenSSL::Cipher.new(CIPHER_NAME)
    cipher.encrypt
    set_key_iv(pass, salt, cipher)
    encrypted = cipher.update(data) + cipher.final
    Base64.strict_encode64(encrypted)
  end

  def decrypt(pass, salt, encrypted)
    encrypted = Base64.strict_decode64(encrypted)
    cipher = OpenSSL::Cipher.new(CIPHER_NAME)
    cipher.decrypt
    set_key_iv(pass, salt, cipher)
    cipher.update(encrypted) + cipher.final
  end

  def set_key_iv(pass, salt, cipher)
    salt = Base64.strict_decode64(salt)
    key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pass, salt, 2000, cipher.key_len + cipher.iv_len)
    key = key_iv[0, cipher.key_len]
    iv = key_iv[cipher.key_len, cipher.iv_len]
    cipher.key = key
    cipher.iv = iv
  end

  def get_pass_salt_from_git(options = {})
    pass = `git config watch-list.pass`.strip
    salt = `git config watch-list.salt`.strip

    if options[:validate]
      raise 'cannot get "watch-list.pass" from git config' if pass.empty?
      raise 'cannot get "watch-list.salt" from git config' if salt.empty?
    end

    [pass, salt]
  end

  def git_encryptable?
    pass, salt = get_pass_salt_from_git
    not pass.empty? and not salt.empty?
  end

  def encrypted_value?(value)
    value.kind_of?(Hash) and value.has_key?(:secure)
  end
end
