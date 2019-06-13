# Kubernettes e2e image

**Run tests:**

* Build image:

```
docker build -t IMAGENAME:IMAGETAG .

```  

* Run tests:
 * Pull image to kubernetes controller node where API is accessible via http://localhost:8080.
 * Run tests:
 ```
mkdir -p /var/log/results
export E2E_REPORT_DIR=/var/log/results
docker run --rm --net=host -e E2E_REPORT_DIR=${E2E_REPORT_DIR} -e API_SERVER=http://localhost:8080/ -v /var/log/results:${E2E_REPORT_DIR} IMAGENAME:IMAGETAG
 ```
 * Analyze tests results in ./results folder. Tests will provide full log of tests job plus results in junit xml format.
