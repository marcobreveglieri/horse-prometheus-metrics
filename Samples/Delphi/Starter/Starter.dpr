program Starter;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Prometheus.Metrics,
  Prometheus.Collectors.Counter,
  Prometheus.Registry;

begin

  try

    // Enables Prometheus Client metrics exposure middleware.
    THorse.Use('/metrics', PrometheusMetrics());

    // Creates a Prometheus "counter" metric to count HTTP handled requests
    // and registers it into the default collector registry for later access;
    // the counter will store different values varying by path and status code.
    TCounter
      .Create('http_requests_handled', 'Count all HTTP handled requests', ['path', 'status'])
      .Register();

    // Creates a test endpoint using Horse web framework.
    THorse.Get('/ping',
      procedure(Req: THorseRequest; Res: THorseResponse)
      begin
        // Increments the "counter" metric value specifying label values.
        TCollectorRegistry.DefaultRegistry
          .GetCollector<TCounter>('http_requests_handled')
          .Labels([Req.PathInfo, IntToStr(Res.Status)]) // ['path', 'status']
        .Inc();

        // Sends a sample response to the client.
        Res.Send('pong');
      end);

    // Creates another test endpoint using Horse web framework.
    THorse.Get('/secret',
      procedure(Req: THorseRequest; Res: THorseResponse)
      begin
        // You are not authorized to see this!
        Res.Status(THTTPStatus.Unauthorized);

        // Increments the "counter" metric value specifying label values.
        TCollectorRegistry.DefaultRegistry
          .GetCollector<TCounter>('http_requests_handled')
          .Labels([Req.PathInfo, IntToStr(Res.Status)]) // ['path', 'status']
        .Inc();

        // Sends a sample response to the client.
        Res.Send('Access denied');
      end);

    // Starts the Horse web server listening to port 9000.
    THorse.Listen(9000);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
