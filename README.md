# aws-lambda-overprovisioned-memory
Script to check AWS Lambda functions for over-provisioned memory

Provisioning the exact RAM allocation for AWS Lambda functions is often a trial and error procedure and, it has happened to us that we set a huge catch-all value for development which sometimes forgets been tuned for production and other more usage intensive environments, where inadequate RAM setting might lead to wasted and unnecessary costs.

Using Cloudwatch Log Insights and their provided **Sample Query** to **Determine the amount of overprovisioned memory**, I've built a bash script (tested on OSX only, which actually leads to issues on date handling on other OS) which analyzes or your Lambda related CloudWatch logs to scan for usage statistics and report possible allocation overhead.

**NOTE 1**: the reported overprovisioning does NOT necessarily mean that you should lower your setting by that exact amount but, experiment on lowering accordingly.

**NOTE 2**: lowering RAM setting has a direct correlation with assigned CPU resources, so you Lambdas may take longer to execute thus, less RAM does not always mean less cost.
