# frozen_string_literal: true

RSpec.describe Layout do
  let(:good_data) do
    [
      ['', '', '', 1],
      ['', '', '', 2],
      ['', '', '', 3],
      ['', '', '', 4],
      ['', '', '', 5],
      ['', '', '', 6],
      ['', '', '', 7],
      ['', '', '', 8],
      ['', '', '', 9],
      ['', '', '', 10]

    ]
  end

  it 'Lays out data points into an alternating pattern to give a good radial layout in a pie chart' do
    res = subject.class.layout(good_data)

    expect(res[0][3]).to equal(10)
    expect(res[1][3]).to equal(1)
    expect(res[2][3]).to equal(8)
    expect(res[3][3]).to equal(2)
    expect(res[4][3]).to equal(7)
    expect(res[5][3]).to equal(9)
    expect(res[6][3]).to equal(3)
    expect(res[7][3]).to equal(6)
    expect(res[8][3]).to equal(4)
    expect(res[9][3]).to equal(5)
  end
end
