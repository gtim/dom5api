<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';

$app = AppFactory::create();

$middleware = $app->addErrorMiddleware(true,true,true);

$app->get( '/', function( Request $request, Response $response, $args ) {
	$response->getBody()->write("Hello world!");
	return $response;
});



#
# /items/{id}
# 

$app->get( '/items/{id:[0-9]+}', function( Request $request, Response $response, array $args ) {
	require_once('inc/Item.php');
	$item = Item::from_id( $args['id'] );
	if ($item) {
		$response->getBody()->write(
			json_encode( $item, JSON_UNESCAPED_SLASHES )
		);
		return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
	} else {
		return $response->withHeader('Content-Type', 'application/json')->withStatus(404);
	}
});

#
# /items?name=...
# /items?name=...&match=fuzzy
#
# returns array of matching items 
#

$app->get( '/items', function( Request $request, Response $response, array $args ) {
	$params = $request->getQueryParams();

	# ensure name query parameter was supplied
	if ( ! array_key_exists( 'name', $params ) ) {
		$response->getBody()->write( json_encode( [ 'errors' => [ [
			'title' => 'Query parameter "name" not specified'
		] ] ] ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
	} 

	require_once('inc/Item.php');

	if ( array_key_exists( 'match', $params ) && $params['match'] == 'fuzzy' ) {
		$items = Item::items_with_similar_name( $params['name'] );
	} else {
		$items = Item::items_with_name( $params['name'] );
	}
	$response->getBody()->write(
		json_encode( array( 'items' => $items ), JSON_UNESCAPED_SLASHES )
	);
	return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
});

$app->run();
