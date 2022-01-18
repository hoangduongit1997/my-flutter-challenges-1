import 'package:flutter/material.dart';
import 'package:nicolau/models/movie_model.dart';
import 'package:nicolau/screens/movie_details/details_movie_screen.dart';
import 'package:nicolau/shared/widgets/date_release_widget.dart';
import 'package:nicolau/shared/widgets/percent_widget.dart';
import 'package:nicolau/shared/widgets/title_widget.dart';
import 'package:nicolau/utils/myBackgroundColors.dart';
import 'package:nicolau/utils/responsive.dart';
import 'package:nicolau/widgets/custom_widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ItemMovie extends StatelessWidget {
  ItemMovie({Key? key, required this.movie}) : super(key: key);
  final Movie movie;
  final BorderRadius borderRadius = const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );
  @override
  Widget build(BuildContext context) {
    final percent = ((movie.voteAverage * 100) / 10);
    movie.uiniqueId = '${movie.id}-card';
    //responsive
    final responsive = Responsive.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => DetailsMovieScreen(
              movie: movie,
            ),
          ),
        );
      },
      child: _itemMovie(context, responsive, percent),
    );
  }

  Widget _itemMovie(
      BuildContext context, Responsive responsive, double percent) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                SizedBox(height: responsive.hp(2)),
                _image(responsive),
                SizedBox(
                  height: responsive.hp(5),
                ),
                titleWidget(responsive, movie.title),
                SizedBox(height: responsive.hp(1)),
                dateReleaseWidget(responsive, movie.releaseDate),
              ],
            ),
            percentWidget(
                responsive: responsive,
                percent: percent,
                movie: movie,
                value: 8.5),
          ],
        ),
      ),
    );
  }

  ClipRRect _image(Responsive responsive) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        margin: const EdgeInsets.all(8),
        height: 300,
        width: responsive.wp(52),
        child: Hero(
            tag: movie.uiniqueId,
            child: FadeInImage(
              image: NetworkImage(movie.getPosterImg()),
              placeholder: const AssetImage('assets/no-image.jpg'),
              fit: BoxFit.cover,
            )),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
