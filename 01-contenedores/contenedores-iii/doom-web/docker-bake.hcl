group "default" {
    targets = ["doom-web"]
}

target "doom-web" {
    context = "."
    dockerfile = "Dockerfile"
    tags = ["doom-web:v6", "0gis0/doom-web:bake"]

    no-cache = true
    platforms = ["linux/amd64", "linux/arm64"]
}