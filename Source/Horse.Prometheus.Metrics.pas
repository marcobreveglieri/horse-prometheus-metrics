unit Horse.Prometheus.Metrics;

interface

uses
  Horse;

function PrometheusMetrics: THorseCallback;

implementation

uses
  System.Classes,
  System.SysUtils,
  Prometheus.Registry,
  Prometheus.Exposers.Text;

procedure PrometheusCallback(AReq: THorseRequest; ARes: THorseResponse;
  ANext: TNextProc);
begin
  var LStream := TMemoryStream.Create;
  try
    var LWriter := TTextExposer.Create;
    try
      LWriter.Render(LStream, TCollectorRegistry.DefaultRegistry.Collect());
    finally
      LWriter.Free;
    end;
  except
    LStream.Free;
    raise;
  end;
  ARes.RawWebResponse.ContentStream := LStream;
  ARes.RawWebResponse.ContentType := Format('text/plain; charset=%s', ['utf-8']);
  ARes.RawWebResponse.StatusCode := Integer(THTTPStatus.OK);
  ARes.RawWebResponse.SendResponse;
end;

function PrometheusMetrics: THorseCallback;
begin
  Result := PrometheusCallback;
end;

end.
