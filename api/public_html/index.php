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
# /units/{id}
# /sites/{id}
# /mercs/{id}
# 

function gen_route_callback_get_by_id( string $class ) {
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
$app->get( "/units/{id:[0-9]+}",      gen_route_callback_get_by_id('Unit') );
$app->get( "/sites/{id:[0-9]+}",      gen_route_callback_get_by_id('Site') );
$app->get( "/mercs/{id:[0-9]+}",      gen_route_callback_get_by_id('Merc') );

#
# /items?name=...
# /items?name=...&match=fuzzy
# and corresponding for spells, units, sites and mercs.
#
# returns array of matching items 
#

function gen_route_callback_get_by_name( string $class, string $category ) {
	# e.g. class: "Item", category: "items"
	return function( Request $request, Response $response, array $args ) use($class,$category) {
		$params = $request->getQueryParams();

		# ensure name query parameter was supplied
		if ( ! array_key_exists( 'name', $params ) ) {
			$response->getBody()->write( json_encode( [ 'errors' => [ [
				'title' => 'Query parameter "name" not specified'
			] ] ] ) );
			return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
		} 

		require_once("inc/$class.php");

		$extra_filters = array();
		if ( $class == 'Unit' && array_key_exists( 'size', $params ) ) {
			if ( ! in_array( $params['size'], [1,2,3,4,5,6] ) ) {
				$response->getBody()->write( json_encode( [ 'errors' => [ [
					'title' => 'Invalid size value'
				] ] ] ) );
				return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
			}
			$extra_filters[] = [ 'size', '=', $params['size'] ];
		}

		if ( array_key_exists( 'match', $params ) && $params['match'] == 'fuzzy' ) {
			$items = $class::entities_with_similar_name( $params['name'], $extra_filters );
		} else {
			$filter = array_merge( [ [ 'name', '=', $params['name'] ] ], $extra_filters );
			$items = $class::entities_by_filter($filter);
		}
		$data = array( $category => $items );
		$response->getBody()->write( json_encode( $data, JSON_UNESCAPED_SLASHES ) );
		return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
	};
}


$app->get( '/items',      gen_route_callback_get_by_name( 'Item', 'items' ) );
$app->get( '/spells',     gen_route_callback_get_by_name( 'Spell', 'spells' ) );
$app->get( '/units',      gen_route_callback_get_by_name( 'Unit', 'units' ) );
$app->get( '/sites',      gen_route_callback_get_by_name( 'Site', 'sites' ) );
$app->get( '/mercs',      gen_route_callback_get_by_name( 'Merc', 'mercs' ) );

$app->run();
?>
