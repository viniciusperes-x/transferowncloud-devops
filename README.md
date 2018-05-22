# INSTALANDO OWNCLOUD EM SUA INSTANCIA AWS 

## INTRODUÇÃO
O objetivo deste artigo implantar um aplicativo simples para fornecer um espaço de transferência de arquivos para usuários, utilizando OwnCloud. A implantação sera totalmente automatizada utilizando de Terraform e Docker para construir a automação no ambiente da AWS.

## PRÉ-REQUISITO

1. Ter instalado o Terraform : é muito fácil instalá-lo, se você ainda não o fez. Você pode encontrar as instruções em: https://www.terraform.io/intro/getting-started/install.html
2. Será necessário ter uma conta na AWS, onde iremos através do script fazer o login nas máquinas e a instalação, você precisa ter uma AWS keypairs já criada na região de sua escolha e baixada na sua máquina, veja no link: https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/ec2-key-pairs.html, e também sera necessário criar um usuário em sua conta da AWS, veja no link: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html

## A ESTRUTURA DE ARQUIVOS
O Terraform elabora todos os arquivos dentro do diretório de trabalho, portanto, não importa se tudo está contido em um único arquivo ou dividido em muitos, embora seja conveniente organizar os recursos em grupos lógicos e dividi-los em arquivos diferentes. Vamos dar uma olhada em como podemos fazer isso de forma eficaz:

### VARIABLES.TF


```bash
#configuração geral
variable "credentials_file" {
  default = "~/.aws/credentials"
  description = "utilizar o local de suas credencias da AWS"
}

variable "profile" {
  default = "default"
}

variable "region" {
  default = ""
  description = "selecionar sua região, ex: us-west-2"
}

variable "ami" {
  default = ""
  description = "utilizar a ami preferencial, ex: ami-b73b63a0"
}

variable "instance_type" {
  default = ""
  description = "utilizar o tipo de instancia escolhida, ex: t2.micro"
}

variable "keyname" {
  default = ""
  description = "utilizar a chave ssh que logue nas máquinas EC2"
}

variable "vpc_sg_ids" {
  default = ""
  description = "utilizar o tipo de vpc, ex: sg-e51b9aad"
}

variable "subnet_id" {
  default = ""
  description = "utilizar o tipo de subnet, ex: subnet-0a778e56"
}

variable "volume_size" {
  default = "20"
  description = "utilizar o tamanho de disco, ex: 20"
}

variable "volume_type" {
  default = "gp2"
  description = "utilizar o tipo de disco, ex: gp2"
}

variable "delete_termination" {
  default = "True"
}

variable "name_server" {
  default = "server-owncloud"
  description = "utilizar descrever o nome do seu ec2, ex: server-owncloud"
}
```

Todas as variáveis são definidas no arquivo variables.tf. Antes de executar o comando “terraform apply”, você precisa definir o seu access e secretkey. Se você também quiser fazer o login na máquina do EC2, certifique-se de preencher o nome da chave também. Cada variável é do tipo String, então tome os devidos duidados no momento de definir.


### CREATESERVER.TF

```bash
provider "aws" {
  shared_credentials_file = "${var.credentials_file}"
  profile = "${var.profile}"
  region = "${var.region}"


}

resource "aws_instance" "owncloud" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.keyname}"
  user_data = "${file("template.sh")}"
  vpc_security_group_ids = ["${aws_security_group.allow_ports.id}"]
 root_block_device {
    volume_size = "${var.volume_size}"
    volume_type = "${var.volume_type}"
    delete_on_termination = "${var.delete_termination}"
  }

  tags {
    Name = "${var.name_server}"
  }
 lifecycle {
	ignore_changes = ["aws_instance.owncloud.id"]
}
}

```

Foi escolhido a opção de provider AWS, pois tenho maior familiaridade com o ambiente, setamos as credenciais conforme declarado em `variables.tf`. Setamos o nome da variavel escolhida para aws_instance, escolhemos a AWS Linux AMI. Em `vpc_security_group_ids`, digite o nome da variavel escolhida no arquivo abaixo `securitygroups.tf`. Com o lifecycle setamos o comportamento do ciclo de vida do recurso, permitindo com `ignore_changes` a possibilidadeque os atributos individuais sejam ignorados por meio de alterações.



### SECURITYGROUPS.TF

```bash

resource "aws_security_group" "allow_ports" {
  
  name        = "allow_ports_owncloud"
  description = "Allow :80 and :443 traffic"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 65535 
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    Name = "allow_ports_owncloud"
  }
}

```

Neste arquivo designamos as portas de conexão de entrada e saida da aplicação. Foi implmentada as portas 80 e 443. Setamos o nome da variavel como `allow_ports`, conforme mencionado acima para haver integração entre o EC2 e SG selecionado. Em `name` descrevemos o nome do SG a ser criado e relacionado ao EC2. Escolhemos permitir a porta 443, para uma futura melhoria na escolha de aplicar um SSL.


### TEMPLATE.SH
```bash

#!/bin/bash

yum install docker -y
sleep 10
/etc/init.d/docker start

docker run -d -p 80:80 owncloud:8.1

```

O objetivo deste arquivo é a instalação facilitada do Docker, aguardar a sua criação e inicia-lo onde rodamos o comando para importar do repositório oficial da docker o repositório [OwnCloud](https://hub.docker.com/_/owncloud/), assim completar o objetivo passado em nossa descrição.


## EXECUTANDO O TERRAFORM
​
Crie todos os arquivos com extensão .tf dentro de um diretório, de permissão de execução para o arquivo .sh `chmod +x template.sh`, substitua os valores na `variavles.tf` conforme explicado na primeira parte do artigo e, em seguida, execute o comando:

```bash
$ terraform init
```
O comando terraform init é usado para inicializar um diretório de trabalho contendo arquivos de configuração do Terraform. Este é o primeiro comando que deve ser executado depois de escrever uma nova configuração do Terraform ou clonar um existente a partir do controle de versão. É seguro executar este comando várias vezes.

```bash
$ terraform plan
```
O comando terraform plan é usado para criar um plano de execução. O Terraform executa uma atualização, a menos que seja explicitamente desabilitado, e determina quais ações são necessárias para atingir o estado desejado especificado nos arquivos de configuração.

```bash
$ terraform apply

```
O comando terraform apply é usado para aplicar as mudanças necessárias para atingir o estado desejado da configuração ou o conjunto predeterminado de ações geradas por um plano de execução do `terraform plan`.

## CONECTANDO AO APLICATIVO

Após executar o comando `terraform apply`, no painel AWS é possível verificar a instancia criada, para conectar na aplicação selecionamos o IP informado em IPv4 conforme mostrado na imagem abaixo:

![ec2ipv4-serverowncloud](https://user-images.githubusercontent.com/39412518/40384584-54efbef8-5dda-11e8-975a-0b6edf79d4ed.png)

Em um navegador web, é possível verificar o painel de acesso, onde os dados para login seguem abaixo:

```bash
Login: Admin
Senha: Admin
```
![owncloud1dashboard](https://user-images.githubusercontent.com/39412518/40384583-54cc78c6-5dda-11e8-903f-41f2ef193167.png)


Este é o painel final, onde podemos gerenciar os usurios, arquivos e diretórios.

![owncloud2dashboard](https://user-images.githubusercontent.com/39412518/40384582-54a86472-5dda-11e8-8c8b-a14b9f1740e5.png)


## ALTERAÇÕES NO TERRAFORM

Para qualquer alteração não é necessário destruir a instância ou faze-lo manual, o Terraform é um gerenciador de infraestrutura por este motivo, ele gerencia completamente a sua infraestrutura, por um exemplo simples onde é necessário alterar o nome de sua instancia:

1. Altere o arquivo `variables.tf`

2. Rode `terraform plan`, verifique em seu terminal que ele mostrara as mudanças.

3. Rode `terraform apply`, e verifique em produção que as mudanças desejadas foram aplicadas.

Com esse exemplo posso exemplificar o funcionamento de sua gerenciabilidade, é sim, é possível utiliza-lo em larga escala.




```bash
$ terraform destroy

```
O comando terraform destroy é usado para destruir a infraestrutura gerenciada pela Terraform. Cuidado! :shipit:


#transferowncloud-devops
