## Deploy Your Environment
./cdn-setup-script.sh

## View and Test Performance of Non-Cached Website
* Get the http-lb loadbalancer ip and view from website
* login to `testing-instance` and do some performance test using the below commadn
```bash
# In the SSH session, test your connection to the index.html page:

for i in {1..15};do curl -s -w "%{time_total}\n" -o /dev/null http://<YOUR_LAB_IP_ADDRESS_HERE>/index.html; done

#Test your connection to the page-2.html page:

for i in {1..15};do curl -s -w "%{time_total}\n" -o /dev/null http://<YOUR_LAB_IP_ADDRESS_HERE>/page-2.html; done
```

## Enable Cloud CDN
* Once cdn is enabled, Wait a few minutes, and then return to the browser window or tab with the SSH session open.
```bash
# In the SSH session, test your connection to the index.html page:

for i in {1..15};do curl -s -w "%{time_total}\n" -o /dev/null http://<YOUR_LAB_IP_ADDRESS_HERE>/index.html; done

#Test your connection to the page-2.html page:

for i in {1..15};do curl -s -w "%{time_total}\n" -o /dev/null http://<YOUR_LAB_IP_ADDRESS_HERE>/page-2.html; done
```

## Delete script
* ./delete-cdn-script.sh