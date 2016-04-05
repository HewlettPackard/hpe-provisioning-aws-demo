# HPE provisioning demo on AWS
a Chef cookbook to provision machines on Amazon AWS

## Installation
Just upload cookbook to your chef server with dependencies
```
knife cookbook upload -o . hpe-cookbook --include-dependecies
knife cookbook upload -o . nginx --include-dependecies
knife cookbook upload -o . jboss7 --include-dependecies
```

## Usage
```
chef-client -r hpe-cookbook
```

## Author
Patryk Zabkiewicz patryk.zabkiewicz@hpe.com pzabkiewicz@gmail.com

