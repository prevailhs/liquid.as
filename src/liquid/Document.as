package liquid {

  public class Document extends Block {

    // we don't need markup to open this block
    public function Document(tokens:Array) {
      parse(tokens);
    }

    // There isn't a real delimter
    override public function get blockDelimiter():* {
      return [];
    }

    // Document blocks don't need to be terminated since they are not actually opened
    override protected function assertMissingDelimitation():void {
    }
  }
}
