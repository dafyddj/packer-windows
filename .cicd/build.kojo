name: Build boxes
on: [push, pull_request, workflow_dispatch]
jobs:
  run-packer:
    runs-on: macos-12
    env:
      MAKE_VARS: -n
      PACKER_GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      VAGRANT_CLOUD_TOKEN: ${{ secrets.VAGRANT_CLOUD_TOKEN }}
    strategy:
      fail-fast: true
      matrix:
        version: [win81, win10]
    steps:
      - name: Prepare environment
        run: |
          echo ${{ github.event_name }}
          brew install make
      - name: Set up Fido
        uses: actions/checkout@v3
        with:
          repository: pbatard/Fido
          path: Fido
      - name: Get URL
        id: get-url
        shell: pwsh
        run: |
          $url = Fido/Fido.ps1 -GetUrl -Lang Int -Win @{ win81 = "8.1"; win10 = "10" }.${{ matrix.version }}
          echo "::echo::on"
          echo "::set-output name=iso_url::$url"
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Download Windows ISO
        if: github.event_name != 'push'
        run: |
          ISO_FILE=$(echo "${{ steps.get-url.outputs.iso_url }}" | sed 's/.*\/\(.*\.iso\).*/\1/')
          mkdir iso
          wget --no-verbose -O iso/$ISO_FILE "${{ steps.get-url.outputs.iso_url }}"
      - name: Set environment
        if: github.event_name != 'push'
        run: |
          echo "MAKE_VARS=" >> $GITHUB_ENV
<% %w(boot install guestadd update provision export).each do |stage| -%>
      - name: Packer <%= stage %>
        run: |
          gmake ${{ env.MAKE_VARS }} <%= stage %>-${{ matrix.version }}
<% end -%>
      - name: Packer upload
        if: github.ref_name == 'main'
        run: |
          cd upload
          gmake ${{ matrix.version }}
