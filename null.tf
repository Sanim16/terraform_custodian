# create zip file from requirements.txt. Triggers only when the file is updated
resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1(local.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
        echo "creating layers with requirements.txt packages..."

        cd ${path.module}
        # rm -rf ${var.dir_name}
        mkdir ${var.dir_name}

        # Create and activate virtual environment environment using python -m venv...
        ${var.runtime} -m venv env_${var.function_name}
        source ${path.cwd}/env_${var.function_name}/bin/activate

        # Installing python dependencies...
        if [ -f ${local.requirements_path} ]; then
            echo "From: requirement.txt file exists..."  

            # pip install -r ${local.requirements_path} -t ${var.dir_name}/
            pip install -r ${local.requirements_path} --target ${var.dir_name}/ --platform manylinux2014_x86_64 --python-version 3.12
            pip install --target ${var.dir_name}/ rpds-py -t ${var.dir_name}/ --platform manylinux2014_x86_64 --only-binary :all: --python-version 3.12
            zip -r ${local.layer_zip_path} ${var.dir_name}/
         else
            echo "Error: requirement.txt does not exist!"
        fi

        # Deactivate virtual environment...
        deactivate

        #deleting the python dist package modules
        rm -rf ${var.dir_name}

    EOT
  }
  depends_on = [aws_s3_bucket.custodian_bucket]
}
