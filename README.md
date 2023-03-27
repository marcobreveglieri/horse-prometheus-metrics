# horse-prometheus-metrics
**Middleware for Prometheus Client** to expose metrics using *Horse* Web framework

## Prerequisites

This middleware is designed to work with [Horse](https://github.com/HashLoad/horse) Web framework.

If you use another library to build Web Server applications in Delphi (like [DMVC](https://github.com/danieleteti/delphimvcframework), [MARS](https://github.com/andrea-magni/MARS), *Web Broker*, etc.), checkout if there are [samples](https://github.com/marcobreveglieri/prometheus-client-delphi/tree/main/Samples) that can help you out bootstrapping your application or ready-to-use [middlewares](https://github.com/marcobreveglieri/prometheus-client-delphi#middlewares) for your framework.

## How to install

To install this middleware in your project, download source code from GitHub and set the *library path* as usual,
or launch this command to get all the needed packages using [boss](https://github.com/HashLoad/boss) package manager:
``` sh
$ boss install marcobreveglieri/horse-prometheus-metrics
```

NOTE: if you download the package manually, also remember to get and configure the [Prometheus Client for Delphi library](https://github.com/marcobreveglieri/prometheus-client-delphi). This middleware works only with [Horse](https://github.com/HashLoad/horse) Web framework!

## Usage

To use this middleware, enable it calling **THorse.Use()** passing the appropriate callback (see below) specifing the
'/metrics' endpoint (which is the default path scraped by Prometheus server); then, just declare the metrics you need
registering them into the default collection registry.

```delphi
uses Horse, Horse.Prometheus.Metrics,

begin
  THorse.Use('/metrics', PrometheusMetrics());

  TCounter
    .Create('http_requests_handled', 'Count all HTTP handled requests', ['path', 'status'])
    .Register();

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      TCollectorRegistry.DefaultRegistry
        .GetCollector<TCounter>('http_requests_handled')
        .Labels([Req.PathInfo, IntToStr(Res.Status)])
      .Inc();
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

## Test it!

By calling the route **/metrics** (or any different path specified when enabling the middleware)
you will get a plain text response that includes all the current metric values collected from the
default collector registry.

```text
# HELP http_requests_handled Count all HTTP handled requests.
# TYPE http_requests_handled counter
http_requests_handled{path="/ping",status="200"} 4
http_requests_handled{path="/secret",status="401"} 2
```

## Additional info

If you want to know more about Prometheus, visit the [official homepage](https://prometheus.io/) and download the right version of this tool.

This middleware also requires to install the [Prometheus Client for Delphi library](https://github.com/marcobreveglieri/prometheus-client-delphi).
Visit these web sites for getting started and read additional documentation about Prometheus and its client library for Delphi.

**Happy coding! 🧑🏻‍💻**
