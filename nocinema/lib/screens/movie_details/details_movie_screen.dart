import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nocinema/models/Genre.dart';
import 'package:nocinema/models/actor_model.dart';
import 'package:nocinema/models/movie_model.dart';
import 'package:nocinema/providers/movie_provider.dart';
import 'package:nocinema/shared/widgets/date_release_widget.dart';
import 'package:nocinema/shared/widgets/percent_widget.dart';
import 'package:nocinema/theme/theme.dart';
import 'package:nocinema/utils/responsive.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
    context.read<MoviesProvider>().getGenres(movie.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final percent = ((movie.voteAverage * 100) / 10);
    final appTheme = context.watch<ThemeChanger>();
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: newMethod(context, responsive, percent, appTheme),
        ),
      ),
    );
  }

  Stack newMethod(BuildContext context, Responsive responsive, double percent,
      ThemeChanger appTheme) {
    final actores = context.watch<MoviesProvider>().actores;
    return Stack(
      children: [
        //image movie
        imageMovieWidget(movie, context),
        //icon for close screen
        iconCloseDetailScreen(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: responsive.wp(100),
            height: responsive.hp(80),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: appTheme.darkTheme ? Colors.grey[850] : Colors.white,
            ),
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
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
                  ),
                ),
                const SizedBox(height: 7),
                //type movies, action, history etc..
                Center(child: _crearGenres(movie)),
                const SizedBox(height: 10),
                //stars
                //director name
                Center(child: Text(movie.originalTitle)),
                const SizedBox(height: 20),
                Center(
                    child: dateReleaseWidget(
                        responsive, movie.releaseDate.toString())),
                //text actores
                infoWidget(
                  "Elenco Principal",
                ),
                actores.isNotEmpty ? _crearCasting(movie) : _shimmer(),

                infoWidget(
                  "Sinopse",
                ),

                //about movie
                informationMovie(movie.overview),
              ],
            ),
          ),
        ),
      ],
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
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _crearCasting(Movie movie) {
    final actores = context.watch<MoviesProvider>().actores;

    return _createActoresPageView(actores);
  }

  Widget _crearGenres(Movie movie) {
    final genres = context.watch<MoviesProvider>().genres;

    if (genres.isNotEmpty) {
      return _createGenres(genres);
    } else {
      return Text("...");
    }
  }

  Widget _shimmer() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < 20; i++)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    "assets/no-image.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: CachedNetworkImage(
              height: 150,
              imageUrl: actor.getPhoto(),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Image.asset(
                  "assets/no-image.jpg",
                  fit: BoxFit.cover,
                  height: 200,
                ),
              ),
              errorWidget: (context, url, error) =>
                  Center(child: const Icon(Icons.error)),
              fit: BoxFit.cover,
            ),
          ),
          Text(
            actor.name,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _createGenres(List<Genres> genres) {
    return Wrap(
      children: [
        for (var i = 0; i < genres.length; i++) typeMovie(genres[i].name!)
      ],
    );
  }

  Widget typeMovie(String text) {
    return FadeIn(
      child: Container(
        margin: EdgeInsets.all(2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
