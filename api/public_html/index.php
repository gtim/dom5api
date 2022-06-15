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

	$result = '123';
	$db = new SQLite3('data/items.db');
	$stmt = $db->prepare('SELECT id, name FROM items WHERE id=:id');
	$stmt->bindValue(':id', $args['id'], SQLITE3_INTEGER );
	$result = $stmt->execute();
	if ( $row = $result->fetchArray() ) {

		$data = array(
			'id' => $row['id'],
			'name' => $row['name'],
			'screenshot' => sprintf( '/items/%d/screenshot', $row['id'] )
		);
		$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(200);

	} else {

		return $response->withHeader('Content-Type', 'application/json')->withStatus(404);

	}
});

$app->run();
