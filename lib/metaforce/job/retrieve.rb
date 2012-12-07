module Metaforce
  class Job::Retrieve < Job
    status_type :retrieve

    def initialize(client, options={})
      super(client)
      @options = options
    end

    def perform
      @id = client.retrieve(@options).id
      super
    end

    # Public: Unzips the returned zip file to the location.
    def save_to(destination)
      file = Tempfile.new('retrieve')
      file.write(zip_file)
      path = file.path
      file.close

      Zip::ZipFile.open(path) do |zip|
        zip.each do |f|
          path = File.join(destination, f.name)
          FileUtils.mkdir_p(File.dirname(path))
          zip.extract(f, path) { true }
        end
      end
      self
    end

    def zip_file
      Base64.decode64(result.zip_file)
    end
  end
end
