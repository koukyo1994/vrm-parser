require "json"

class Reader
    def initialize(data)
        @data = data
        @pos = 0
    end

    def read_str(size)
        result = @data[@pos, size]
        @pos += size
        result
    end

    def read(size)
        result = @data[@pos, size]
        @pos += size
        result
    end

    def read_uint
        result = @data[@pos, 4].unpack("I")
        @pos += 4
        result[0]
    end
end

def parse_glb(data)
    reader = Reader.new(data)
    if (magic = reader.read_str(4)) != "glTF"
        raise "magic not found: #{magic}"
    end

    if (version = reader.read_uint) != 2
        raise "version: #{version} is not 2"
    end

    size = reader.read_uint - 12
    json_str = nil
    body = nil

    while size > 0
        chunk_size = reader.read_uint
        size -= 4

        chunk_type = reader.read_str(4)
        size -= 4

        chunk_data = reader.read_str(chunk_size)
        size -= chunk_size

        if chunk_type == "BIN\x00"
            body = chunk_data
        elsif chunk_type == "JSON"
            json_str = chunk_data
        else
            raise "unknow chunk_type: #{chunk_type}"
        end
    end

    json = JSON.load(json_str)
    return json, body
end


File.open("AliciaSolid.vrm", "rb") do |f|
    data = f.read
    parsed, body = parse_glb(data)
    puts parsed
end
