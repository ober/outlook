docker:
	docker build --rm=true -t outlook .
	docker tag outlook jaimef/outlook

push:
	docker push jaimef/outlook
