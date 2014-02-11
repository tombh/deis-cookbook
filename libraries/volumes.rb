
class Chef::Recipe::VolumeHelper

  def self.builder(node)
    mounts = []
    if node.deis.builder.packs != nil
      mounts << "#{node.deis.builder.packs}:/buildpacks"
    end
    if node.deis.dev.mode == true
      mounts << "#{File.join(node.deis.dev.source, 'images/builder')}:/app"
    end
    mounts
  end

  def self.cache(node)
    mounts = []
    if node.deis.dev.mode == true
      mounts << "#{File.join(node.deis.dev.source, 'images/cache')}:/app"
    end
    mounts
  end

  def self.database(node)
    mounts = []
    if node.deis.dev.mode == true
      mounts << "#{File.join(node.deis.dev.source, 'images/database')}:/app"
    end
    mounts
  end

  def self.logger(node)
    # share log directory between server and logger components
    # TODO: replace with a distributed mechanism for populating `deis logs`
    mounts = ["#{node.deis.log_dir}:/var/log/deis"]
    if node.deis.dev.mode == true
      mounts << "#{File.join(node.deis.dev.source, 'images/logger')}:/app"
    end
    mounts
  end

  def self.registry(node)
    mounts = []
    if node.deis.dev.mode == true
      mounts << "#{File.join(node.deis.dev.source, 'images/registry')}:/app"
    end
    mounts
  end

  def self.server(node)
    # share log directory between server and logger components
    # TODO: replace with a distributed mechanism for populating `deis logs`
    mounts = ["#{node.deis.log_dir}:/app/deis/logs"]
    if node.deis.dev.mode == true
      mounts = [
        "#{node.deis.dev.source}:/app/deis",
        "#{File.join(node.deis.dev.source, 'images/server/bin')}:/app/bin",
        "#{File.join(node.deis.dev.source, 'images/server/conf.d')}:/app/conf.d",
        "#{File.join(node.deis.dev.source, 'images/server/templates')}:/app/templates" ]
    end
    mounts
  end

  def self.worker(node)
    mounts = []
    if node.deis.dev.mode == true
      mounts.concat [
        "#{node.deis.dev.source}:/app/deis",
        "#{File.join(node.deis.dev.source, 'images/worker/bin')}:/app/bin",
        "#{File.join(node.deis.dev.source, 'images/worker/conf.d')}:/app/conf.d",
        "#{File.join(node.deis.dev.source, 'images/worker/templates')}:/app/templates" ]
      if File.exist?('/home/vagrant')
        mounts << '/home/vagrant:/home/vagrant'
      end
    end
    mounts
  end
end
