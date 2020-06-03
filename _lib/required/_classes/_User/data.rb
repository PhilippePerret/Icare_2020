# encoding: UTF-8
class User
  attr_reader :data

  DATA_GUEST = {
    'id': 0,
    'pseudo': 'Guest',
    'options': '001090000000000011090009'
  }

  def id      ; @id       || get(:id)       end
  def pseudo  ; @pseudo   ||= get(:pseudo)  end
  def mail    ; @mail     ||= get(:mail)    end

  def get key
    @data ||= db_get('users', {id: id})
    @data[key.to_sym]
  end

  def set key, value = nil
    @data ||= db_get('users', {id: id})
    if key.is_a?(Hash)
      @data.merge!(key)
    else
      @data.merge!(key.to_sym => value)
      key = {key.to_sym => value}
    end
    save(key)
  end

  def save(data2save)
    return if guest?
    values  = data2save.values
    columns = data2save.keys.collect{|c| "#{c} = ?"}.join(', ')
    columns << ", updated_at = ?"
    values << Time.now.to_i
    values << id
    request = "UPDATE users SET #{columns} WHERE id = ?"
    debug "request save:#{request}"
    debug "Values save: #{values.inspect}"
    db_exec(request, values)
  end
end #/User
