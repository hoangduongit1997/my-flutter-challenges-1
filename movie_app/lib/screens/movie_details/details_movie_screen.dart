import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nicolau/models/actor_model.dart';
import 'package:nicolau/models/movie_model.dart';
import 'package:nicolau/providers/movie_provider.dart';
import 'package:nicolau/shared/widgets/percent_widget.dart';
import 'package:nicolau/utils/responsive.dart';
import 'package:nicolau/widgets/custom_widgets.dart';
import 'package:provider/provider.dart';

import 'widgets/widgets_details_movie.dart';

class DetailsMovieScreen extends StatefulWidget {
  final Movie movie;
  final bool darkMode;

  const DetailsMovieScreen(
      {Key? key, required this.movie, this.darkMode = false})
      : super(key: key);

  @override
  State<DetailsMovieScreen> createState() => _DetailsMovieScreenState();
}

class _DetailsMovieScreenState extends State<DetailsMovieScreen> {
  late final Movie movie;

  @override
  void initState() {
    super.initState();
    movie = widget.movie;
    context.read<MoviesProvider>().getCast(movie.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final percent = ((movie.voteAverage * 100) / 10);
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              //image movie
              imageMovieWidget(movie),
              //icon for close screen
              iconCloseDetailScreen(context),
              Positioned(
                bottom: 0,
                child: Container(
                  width: responsive.wp(100),
                  height: responsive.hp(80),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      //title movie
                      titleMovieWidget(
                        movie,
                      ),
                      const SizedBox(height: 7),
                      Center(
                        child: percentWidget(
                            responsive: responsive,
                            percent: percent,
                            movie: movie,
                            value: 0),
                      ),
                      const SizedBox(height: 7),
                      //type movies, action, history etc..
                      typeMovieWidget(),
                      const SizedBox(height: 10),
                      //stars
                      //director name
                      Center(child: Text(movie.originalTitle)),
                      const SizedBox(height: 20),

                      //text actores
                      infoWidget(
                        "Actores",
                      ),
                      _crearCasting(movie),

                      infoWidget(
                        "History",
                      ),

                      //about movie
                      Expanded(
                        child: informationMovie(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row typeMovieWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        typeMovie("Action"),
        const SizedBox(width: 7),
        typeMovie("Drama"),
        const SizedBox(width: 7),
        typeMovie("History"),
      ],
    );
  }

  Center titleMovieWidget(
    movie,
  ) {
    return Center(
      child: Text(
        widget.movie.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 20,
          color: Colors.grey[850],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _crearCasting(Movie movie) {
    final actores = context.watch<MoviesProvider>().actores;

    if (actores.isNotEmpty) {
      return _createActoresPageView(actores);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _createActoresPageView(List<Actor> actores) {
    return SizedBox(
      height: 200.0,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        pageSnapping: false,
        controller: PageController(viewportFraction: 0.3, initialPage: 1),
        itemCount: actores.length,
        itemBuilder: (context, i) => _actorCard(actores[i]),
      ),
    );
  }

  Widget _actorCard(Actor actor) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: CachedNetworkImage(
            height: 150,
            imageUrl: actor.getPhoto(),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Image.asset(
              "assets/no-image.jpg",
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        ),
        Text(
          actor.name,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  Container typeMovie(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[850],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(30)),
    );
  }
}
