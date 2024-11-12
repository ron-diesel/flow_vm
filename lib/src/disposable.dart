/// An abstract interface class that defines a disposable resource.
///
/// The [Disposable] interface is used to ensure that classes implement a [dispose] method
/// to release any resources when they are no longer needed.
abstract interface class Disposable {
  /// Disposes the resources used by the implementing class.
  void dispose();
}
