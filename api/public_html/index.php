<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';

$app = AppFactory::create();

$middleware = $app->addErrorMiddleware(true,true,true);


#
# /items/{id}
# /spells/{id}
# /commanders/{id}
# /units/{id}
# /sites/{id}
# /mercs/{id}
# 

function gen_route_callback_get_by_id( string $class) {
	return function( Request $request, Response $response, array $args ) use($class) {
		require_once("inc/$class.php");
		$entity = $class::from_id( $args['id'] );
		if ($entity) {
			$response->getBody()->write(
				json_encode( $entity, JSON_UNESCAPED_SLASHES )
			);
			return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
		} else {
			return $response->withHeader('Content-Type', 'application/json')->withStatus(404);
		}
	};
}

$app->get( "/items/{id:[0-9]+}",      gen_route_callback_get_by_id('Item') );
$app->get( "/spells/{id:[0-9]+}",     gen_route_callback_get_by_id('Spell') );
$app->get( "/commanders/{id:[0-9]+}", gen_route_callback_get_by_id('Commander') );
$app->get( "/units/{id:[0-9]+}",      gen_route_callback_get_by_id('Unit') );
$app->get( "/sites/{id:[0-9]+}",      gen_route_callback_get_by_id('Site') );
$app->get( "/mercs/{id:[0-9]+}",      gen_route_callback_get_by_id('Merc') );

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
		$items = Item::entities_with_similar_name( $params['name'], $similarity );
	} else {
		$items = Item::entities_with_name( $params['name'] );
	}
	$data = array( 'items' => $items );
	$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
	return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
});

#
# /spells?name=...
# /spells?name=...&match=fuzzy
#
# returns array of matching spells 
#

$app->get( '/spells', function( Request $request, Response $response, array $args ) {
	$params = $request->getQueryParams();

	# ensure name query parameter was supplied
	if ( ! array_key_exists( 'name', $params ) ) {
		$response->getBody()->write( json_encode( [ 'errors' => [ [
			'title' => 'Query parameter "name" not specified'
		] ] ] ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
	} 

	require_once('inc/Spell.php');

	if ( array_key_exists( 'match', $params ) && $params['match'] == 'fuzzy' ) {
		$items = Spell::entities_with_similar_name( $params['name'], $similarity );
	} else {
		$items = Spell::entities_with_name( $params['name'] );
	}
	$data = array( 'spells' => $items );
	$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
	return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
});

#
# /units?name=...
# /units?name=...&match=fuzzy
#
# returns array of matching units 
#

$app->get( '/units', function( Request $request, Response $response, array $args ) {
	$params = $request->getQueryParams();

	# ensure name query parameter was supplied
	if ( ! array_key_exists( 'name', $params ) ) {
		$response->getBody()->write( json_encode( [ 'errors' => [ [
			'title' => 'Query parameter "name" not specified'
		] ] ] ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
	} 

	require_once('inc/Unit.php');

	if ( array_key_exists( 'match', $params ) && $params['match'] == 'fuzzy' ) {
		$items = Unit::entities_with_similar_name( $params['name'], $similarity );
	} else {
		$items = Unit::entities_with_name( $params['name'] );
	}
	$data = array( 'units' => $items );
	$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
	return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
});

#
# /commanders?name=...
# /commanders?name=...&match=fuzzy
#
# returns array of matching commanders 
#

$app->get( '/commanders', function( Request $request, Response $response, array $args ) {
	$params = $request->getQueryParams();

	# ensure name query parameter was supplied
	if ( ! array_key_exists( 'name', $params ) ) {
		$response->getBody()->write( json_encode( [ 'errors' => [ [
			'title' => 'Query parameter "name" not specified'
		] ] ] ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
	} 

	require_once('inc/Commander.php');

	if ( array_key_exists( 'match', $params ) && $params['match'] == 'fuzzy' ) {
		$items = Commander::entities_with_similar_name( $params['name'], $similarity );
	} else {
		$items = Commander::entities_with_name( $params['name'] );
	}
	$data = array( 'commanders' => $items );
	$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
	return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
});

#
# /sites?name=...
# /sites?name=...&match=fuzzy
#
# returns array of matching sites 
#

$app->get( '/sites', function( Request $request, Response $response, array $args ) {
	$params = $request->getQueryParams();

	# ensure name query parameter was supplied
	if ( ! array_key_exists( 'name', $params ) ) {
		$response->getBody()->write( json_encode( [ 'errors' => [ [
			'title' => 'Query parameter "name" not specified'
		] ] ] ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
	} 

	require_once('inc/Site.php');

	if ( array_key_exists( 'match', $params ) && $params['match'] == 'fuzzy' ) {
		$items = Site::entities_with_similar_name( $params['name'], $similarity );
	} else {
		$items = Site::entities_with_name( $params['name'] );
	}
	$data = array( 'sites' => $items );
	$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
	return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
});

#
# /mercs?name=...
# /mercs?name=...&match=fuzzy
#
# returns array of matching mercs 
#

$app->get( '/mercs', function( Request $request, Response $response, array $args ) {
	$params = $request->getQueryParams();

	# ensure name query parameter was supplied
	if ( ! array_key_exists( 'name', $params ) ) {
		$response->getBody()->write( json_encode( [ 'errors' => [ [
			'title' => 'Query parameter "name" not specified'
		] ] ] ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
	} 

	require_once('inc/Merc.php');

	if ( array_key_exists( 'match', $params ) && $params['match'] == 'fuzzy' ) {
		$items = Merc::entities_with_similar_name( $params['name'], $similarity );
	} else {
		$items = Merc::entities_with_name( $params['name'] );
	}
	$data = array( 'mercs' => $items );
	$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
	return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
});


$app->run();
?>
