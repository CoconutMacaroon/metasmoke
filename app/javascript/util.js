import createDebug from 'debug';

const debug = createDebug('ms:util');
// Common utilities

// call `enter`(pathname) when visiting `path` (string orregex)
// call `exit`(pathname) when leaving `path`
const routes = [];
$(document).on('turbolinks:load', () => {
  const { pathname } = location;
  for (const route of routes) {
    if (route.pathisRe ? pathname.match(route.path) : route.path === pathname) {
      route.enter.call(null, pathname);
      route.current = true;
    }
    else if (route.current) {
      route.current = false;
      route.exit.call(null, pathname);
    }
  }
});

$(window).on('beforeunload', () => {
  debug('onbeforeunload');
  const route = routes.find(route => route.current) || { exit: () => {} };
  route.current = false;
  route.exit.call(null);
});

export function route(path, enter, exit = () => {}) {
  if (!path || !enter) {
    throw new Error('Expecting at least two arguments to utils.route(), got: ' + JSON.stringify(arguments));
  }
  routes.push({
    path,
    pathisRe: path instanceof RegExp,
    enter,
    exit,
    current: false
  });
}

export function onLoad(cb) {
  $(document).on('turbolinks:load', cb);
}
