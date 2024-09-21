# API Service Example

This project illustrates how to use the [API Service](https://github.com/alejandroivan/APIService) library, both with SSL pinning enabled (DER certificate and string hashes) and disabled.

Right now it's only implementing GET requests (even though all DELETE, GET, POST and PUT should work), but I don't have an example API at hand that accepts those requests to illustrate.

The main `ViewController` only shows a `.systemPink` background color. Check out its code to see different ways of instantiating the API and the Example network requests.

This Example project is set up to be compiled using Swift 6.