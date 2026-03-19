require "rails_helper"

RSpec.describe MessageHtmlRenderer do
  it "renders top-level message partial" do
    controller = instance_double(Api::V1::MessagesController)
    message = instance_double(Message, parent_message_id: nil)

    expect(controller).to receive(:render_to_string).with(
      partial: "messages/message",
      formats: [ :html ],
      locals: { message: message }
    ).and_return("<div>message</div>")

    html = described_class.call(controller: controller, message: message)

    expect(html).to eq("<div>message</div>")
  end

  it "renders comment partial for replies" do
    controller = instance_double(Api::V1::MessagesController)
    message = instance_double(Message, parent_message_id: 10)

    expect(controller).to receive(:render_to_string).with(
      partial: "messages/comment",
      formats: [ :html ],
      locals: { comment: message, level: 2 }
    ).and_return("<div>comment</div>")

    html = described_class.call(controller: controller, message: message, comment_level: 2)

    expect(html).to eq("<div>comment</div>")
  end
end
