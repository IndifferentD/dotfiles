"""Convert a VLESS share URL on stdin to an Xray client config on stdout."""

import json
import sys
from urllib.parse import parse_qs, unquote, urlsplit


def make_config(link):
    url = urlsplit(link.strip())
    if url.scheme != "vless" or not url.username or not url.hostname or not url.port:
        raise ValueError("Expected vless://id@host:port?parameters")
    if url.password is not None or url.path not in ("", "/"):
        raise ValueError("Unexpected password or path in VLESS URL")
    params = parse_qs(url.query, keep_blank_values=True)
    if any(len(values) != 1 for values in params.values()):
        raise ValueError("Duplicate URL parameters are not supported")

    def take(key, default=""):
        return params.pop(key, [default])[0]

    network = take("type", "tcp")
    network = {"raw": "tcp", "websocket": "ws"}.get(network, network)
    if network not in ("tcp", "ws", "grpc", "httpupgrade", "xhttp"):
        raise ValueError("Supported transports: tcp/raw, ws, grpc, httpupgrade, xhttp")
    security = take("security", "none")
    if security not in ("none", "tls", "reality"):
        raise ValueError("Supported security modes: none, tls, reality")
    user = {"id": unquote(url.username), "encryption": take("encryption", "none")}
    if not user["encryption"]:
        raise ValueError("encryption must not be empty")
    flow = take("flow")
    if flow:
        user["flow"] = flow
    stream = {"network": network, "security": security}

    if security != "none":
        tls = {"serverName": take("sni", url.hostname), "fingerprint": take("fp", "chrome")}
        if security == "reality":
            if network not in ("tcp", "grpc", "xhttp"):
                raise ValueError("REALITY requires tcp/raw, grpc, or xhttp")
            password = take("pbk")
            if not password:
                raise ValueError("REALITY requires pbk")
            tls.update(password=password, shortId=take("sid"), spiderX=take("spx", "/"))
            pqv = take("pqv")
            if pqv:
                tls["mldsa65Verify"] = pqv
        else:
            alpn = take("alpn")
            if alpn:
                tls["alpn"] = alpn.split(",")
            for query, field in (("ech", "echConfigList"), ("pcs", "pinnedPeerCertSha256"),
                                 ("vcn", "verifyPeerCertByName")):
                value = take(query)
                if value:
                    tls[field] = value
        stream[f"{security}Settings"] = tls

    if network == "tcp":
        if take("headerType", "none") != "none":
            raise ValueError("TCP header obfuscation is not supported")
    elif network in ("ws", "httpupgrade", "xhttp"):
        settings = {"path": take("path", "/")}
        host = take("host")
        if host:
            if network == "ws":
                settings["headers"] = {"Host": host}
            else:
                settings["host"] = host
        if network == "xhttp":
            settings["mode"] = take("mode", "auto")
            extra = take("extra")
            if extra:
                settings["extra"] = json.loads(extra)
                if not isinstance(settings["extra"], dict):
                    raise ValueError("XHTTP extra must be a JSON object")
        stream[f"{network}Settings"] = settings
    elif network == "grpc":
        settings = {"serviceName": take("serviceName")}
        authority = take("authority")
        if authority:
            settings["authority"] = authority
        mode = take("mode", "gun")
        if mode not in ("gun", "multi"):
            raise ValueError("gRPC mode must be gun or multi")
        settings["multiMode"] = mode == "multi"
        stream["grpcSettings"] = settings

    if params:
        raise ValueError("Unsupported URL parameters: " + ", ".join(sorted(params)))
    return {
        "log": {"loglevel": "warning"},
        "inbounds": [{
            "tag": "socks", "listen": "0.0.0.0", "port": 2080, "protocol": "socks",
            "settings": {"auth": "noauth", "udp": True},
            "sniffing": {
                "enabled": True,
                "destOverride": ["http", "tls", "quic"],
                "routeOnly": True,
            },
        }],
        "outbounds": [{
            "tag": "proxy", "protocol": "vless",
            "settings": {"vnext": [{"address": url.hostname, "port": url.port, "users": [user]}]},
            "streamSettings": stream,
        }],
    }


if __name__ == "__main__":
    try:
        config = make_config(sys.stdin.read())
    except (ValueError, UnicodeError):
        # URL parser exceptions can include credentials; never echo the input.
        sys.exit("Invalid or unsupported VLESS link.")
    json.dump(config, sys.stdout, indent=2)
    sys.stdout.write("\n")
