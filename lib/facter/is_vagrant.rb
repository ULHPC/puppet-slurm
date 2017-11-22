Facter.add(:is_vagrant) do
  setcode do
    Facter[:is_virtual].value && File.directory?('/vagrant')
  end
end
