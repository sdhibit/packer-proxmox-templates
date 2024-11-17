source "file" "schematic" {
  content = file("${path.root}/templates/schematic.yaml.pkrtpl.hcl")
  target  = "${path.root}/http/schematic.yaml"
}
