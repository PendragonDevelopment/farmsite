class Shared::Navbar < Bridgetown::Component
  def initialize(metadata:, resource:)
    @metadata, @resource = metadata, resource
  end

  def active?(path)
    @resource.relative_url == path
  end

  def link_classes(path)
    base = "text-sm font-medium transition-colors"
    if active?(path)
      "#{base} text-farm-green"
    else
      "#{base} text-farm-brown hover:text-farm-green"
    end
  end
end
