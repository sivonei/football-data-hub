## Grafana Access

Grafana runs on port 3000 on VM-3 (10.0.2.4) and is not exposed to the internet.
Access is done via SSH tunnel through Azure Bastion:

ssh -L 3000:10.0.2.4:3000 azureuser@<bastion-public-ip> -i ~/.ssh/eve

Then open http://localhost:3000 in the browser.

This approach avoids exposing the monitoring dashboard to the internet,
which is the standard practice in production environments.