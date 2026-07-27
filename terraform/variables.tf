variable "base_bucket_name" {
    description = "Nome base para os buckets do lakehouse"
    type = string
}

variable "user_tag" {
    description = "Nome do usuário para compor o nome do bucket"
    type = string
}