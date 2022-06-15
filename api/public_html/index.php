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

$app->get( '/items/{id}', function( Request $request, Response $response, array $args ) {
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

$app->run();
