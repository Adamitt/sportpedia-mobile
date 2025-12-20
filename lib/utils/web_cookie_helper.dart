import 'dart:html' as html;

void clearSessionCookie() {
  html.document.cookie =
      'sessionid=; Path=/; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT';
}
