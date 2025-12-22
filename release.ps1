# First ensure that the container can be build and tag it.
podman build --no-cache -t uzgizshinyapps.azurecr.io/bilicurve .

# Login to azure
az login
# az acr login --name uzgizshinyapps  --expose-token

# retrieve a token from the container registry for podman to login.
$token = az acr login --name uzgizshinyapps --expose-token --output tsv --query accessToken
$token | podman login --username 00000000-0000-0000-0000-000000000000 --password-stdin uzgizshinyapps.azurecr.io

# push the tagged image.
podman push uzgizshinyapps.azurecr.io/bilicurve